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

		if method
			route = Router mergeParams: true

			interceptors = @getInterceptors name
			interceptors.unshift getIp

			if httpMethod is 'get'
				interceptors.unshift getParamsToBody

			if method.logger and not method.withoutLog
				interceptors.push (promise, req, res) ->
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
				promise = Promise.resolve()
				_.each interceptors, (x) -> promise = x promise, req, res
				promise = promise.then -> method.action req.body, req.$user, req.$session, req, res

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
									res.$logger?.error error.stack
									return Promise.reject error

					responseParsers.push (promise) -> promise.catch -> true

					_.each responseParsers, (x) -> promise = x promise, req, res
			)

		return
