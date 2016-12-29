{Router} = require 'express'

getParamsToBody = require 'app/core/interceptors/get_params_to_body'
getIp = require 'app/core/interceptors/get_ip'
Logger = require 'app/core/Logger'

module.exports = class CoreController
	constructor: (config = {}) ->
		if config.methods
			@methods = config.methods

			_.each @methods, (method, name) ->
				@[name] = method

				if config.logger and not method.logger
					method.logger = new Logger "#{config.logger}/#{name}"
				return

		@interceptors = {}
		@responseParsers = {}

		if config.interceptors
			@interceptors = config.interceptors

		if config.responseParsers
			@responseParsers = config.responseParsers


	getInterceptors: (methodName) ->
		interceptors = @interceptors.all or []
		interceptors = interceptors.concat @methods[methodName].interceptors or []
		interceptors = interceptors.concat @interceptors[methodName] or []

		result = []

		_.each interceptors, (x) ->
			if _.isArray(x)
				result = result.concat x
			else
				result.push x

			return
		return result

	getResponseParsers: (methodName) ->
		responseParsers = @responseParsers.all or []
		responseParsers = responseParsers.concat @methods[methodName].responseParsers or []
		responseParsers = responseParsers.concat @responseParsers[methodName] or []

		result = []

		_.each responseParsers, (x) ->
			if _.isArray(x)
				result = result.concat x
			else
				result.push x

			return
		return result


	getRout: (name, httpMethod = 'post') ->
		method = @methods[name]
		httpMethod = httpMethod.toLocaleLowerCase()

		if not method
			error = new Error "Method `#{name}` not found"
			console.error error.stack

		if method
			route = Router mergeParams: true

			interceptors = @getInterceptors name
			interceptors.unshift getIp

			if httpMethod is 'get'
				interceptors.unshift getParamsToBody

			if method.logger and not method.withoutLog
				interceptors.push (promise, req, res) ->
					promise.then ->
						res.$logMessage = """
							\nRequest:
								user:
									id: #{req.$user?.id}
									name: #{req.$user?.name}
									login: #{req.$user?.login}
								IP: #{req.$ip}
								session.id: #{req.$session?.id}
								body: >>>
								#{try JSON.stringify req.body}
								<<<\n
						"""
						res.$logger = method.logger

			return route[httpMethod]('', (req, res, next) =>
				routPromise = Promise.resolve()
				_.each interceptors, (x) ->
					routPromise = x routPromise, req, res
					return

				routPromise = routPromise.then -> method.action req.body, req.$user, req.$session, req, res

				if not method.withoutAutoResponse
					responseParsers = @getResponseParsers name

					if method.logger and not method.withoutLog
						responseParsers.push (promise, req, res) ->
							promise
								.then (data) ->
									if res.$logger
										res.$logger.log res.$logMessage + """
										Response: >>>
										#{JSON.stringify data}
										<<<\n
									"""
									return data

								.catch (error) ->
									if error and (error.code is 500 or not error.code)
										console.error error.stack or error

									if res.$logger
										res.$logger.log res.$logMessage + """
												Response with Error: >>>
												#{error.stack}
												<<<\n
											"""
										res.$logger.error error.stack
									return Promise.reject error

					responseParsers.push (promise) -> promise.catch -> true

					_.each responseParsers, (x) ->
						routPromise = x routPromise, req, res
						return
			)

		return


	getSocket: (name) ->
		method = @methods[name]

		if not method
			error = new Error "Method `#{name}` not found"
			console.error error.stack

		if method
			return (data, callback, socket) =>
				start = _.now()
				logMessage = ''
				socketPromise = Promise.resolve data
				interceptors = @getInterceptors name
				responseParsers = @getResponseParsers name

				if method.logger and not method.withoutLog
					interceptors.push (promise, socket) ->
						promise.then (data) ->
							logMessage = """
							\nRequest:
								user:
									id: #{socket.$user?.id}
									name: #{socket.$user?.name}
									login: #{socket.$user?.login}
								IP: #{socket.$ip}
								session.id: #{socket.$session?.id}
								body: >>>
								#{try JSON.stringify data}
								<<<\n
							"""
							return data

					responseParsers.push (promise, socket) ->
						promise
							.then (data) ->
								method.logger.log logMessage + """
									Response: >>>
									#{JSON.stringify data}
									<<<\n
								"""
								logMessage = ''
								return data

							.catch (error) ->
								if error and (error.code is 500 or not error.code)
									console.error error.stack or error

								method.logger.log logMessage + """
									Response with Error: >>>
									#{error.stack}
									<<<\n
								"""
								logMessage = ''
								method.logger.error error.stack
								return Promise.reject error

				responseParsers.push (promise) -> promise.catch -> true
				responseParsers.push (promise) -> promise.then -> console.log "Socket event `#{name}` time #{_.now() - start} ms"

				_.each interceptors, (x) ->
					socketPromise = x socketPromise, socket
					return

				socketPromise = socketPromise.then (d) -> method.action d, socket.$user, socket.$session, socket

				_.each responseParsers, (x) ->
					socketPromise = x socketPromise, socket, callback
					return
