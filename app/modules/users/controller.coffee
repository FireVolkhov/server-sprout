ERROR_CODE = require 'app/modules/error_codes'
PLATFORM_TYPE = require './const/platform_type'
REDIS_VARIABLE = require 'app/modules/users/const/redis_variable'

socketIo = require 'app/modules/notification/notification'
redis = require 'app/redis'
sequelize = require 'app/sequelize'

trimmer = require 'app/core/trimmer'
validateRequest = require 'app/core/validate_request'
sessionInterceptor = require 'app/modules/users/interceptors/session'
logInterceptor = require 'app/modules/log/interceptors/log'
jsonResponseParser = require 'app/core/response_parsers/json'
jsonSocketResponseParser = require 'app/core/response_parsers/json_for_socket'
bodyParser = require 'app/core/interceptors/body_parser'
CoreController = require 'app/core/CoreController'
CoreError = require 'app/core/CoreError'


addRedisDisconnect = (session_id) ->
	redis
		.getList REDIS_VARIABLE.DISCONNECTS
		.then ([list]) ->
			if not (_.find list, (x) -> x is session_id)
				redis.pushInRoom REDIS_VARIABLE.DISCONNECTS, session_id

checkRedisDisconnect = (session_id) ->
	redis
		.getList REDIS_VARIABLE.DISCONNECTS
		.then ([list]) -> return !!(_.find list, (x) -> x is session_id)

remRedisDisconnect = (session_id) ->
	socketIo
		.hasSessionSocket session_id
		.then (isHave) ->
			if not isHave
				redis.remInRoom REDIS_VARIABLE.DISCONNECTS, session_id


module.exports = new CoreController
	logger: 'users/controller'

	methods:
		login:
			interceptors: [
				bodyParser
				trimmer ['login', 'password']
				validateRequest.get 'login', ['required', 'string']
				validateRequest.get 'password', ['required', 'string']
				validateRequest.get 'platform_type', ['required']
				validateRequest.enum 'platform_type', [PLATFORM_TYPE.ANDROID, PLATFORM_TYPE.IOS, PLATFORM_TYPE.WEB]
			]
			responseParsers: [jsonResponseParser]
			action: (data, user, session, req, res) ->
				{User, Request} = sequelize.models

				Promise
					.resolve()
					.then -> User.findOne where: login: data.login
					.then (user) ->
						if not user
							return Promise.reject new CoreError ERROR_CODE.BAD_LOGIN_PASS
						return user

					.then (user) ->
						return user
							.checkPassword data.password
							.catch -> Promise.reject new CoreError ERROR_CODE.BAD_LOGIN_PASS

					.then (user) ->
						return Promise.all [
							Request.create user_id: user.id
							user.signin data.platform_type, data.device_id
						]

					.then ([request, [user, session]]) ->
						request.session_id = session.id

						return request.save()
							.then -> return [user, session]
							.catch (e) ->
								if e.name is 'SequelizeForeignKeyConstraintError'
									return Promise.reject new CoreError ERROR_CODE.INVALID_REQUEST

								return Promise.reject e

					.then ([user, session]) ->
						session_id: session.id
						user_id: user.external_id


		subscribe:
			interceptors: []
			responseParsers: [jsonSocketResponseParser]
			action: (data, user, session, socket) ->
				{Session} = sequelize.models
				sessionId = data?.session_id

				console.log '>>> Session', Session
				Session
					.check sessionId
					.then ([user, session]) ->
						socket.$user = user
						socket.$session = session

					.then -> remRedisDisconnect sessionId
					.then -> redis.pushInRoom REDIS_VARIABLE.SESSIONS_ROOMS, sessionId
					.then -> socket.join sessionId
					.then -> true


		disconnect:
			interceptors: []
			responseParsers: [jsonSocketResponseParser]
			action: (data, user, session, socket) ->
				if user and session
					addRedisDisconnect session.id
					redis.remInRoom REDIS_VARIABLE.SESSIONS_ROOMS, session.id


		logout:
			interceptors: [
				bodyParser
				sessionInterceptor
				logInterceptor
			]
			responseParsers: [jsonResponseParser]
			action: (data, user, session) ->
				session
					.destroy()
					.then -> true
