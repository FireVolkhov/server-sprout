ERROR_CODE = require 'app/modules/error_codes'
PLATFORM_TYPE = require './const/platform_type'

trimmer = require 'app/core/trimmer'
validateRequest = require 'app/core/validate_request'
sessionInterceptor = require 'app/modules/users/interceptors/session'
jsonResponseParser = require 'app/core/response_parsers/json'
CoreController = require 'app/core/CoreController'

User = require './models/user'
Request = require 'app/modules/log/models/request'

module.exports = new CoreController
	logger: 'users/controller'

	responseParsers:
		all: [jsonResponseParser]

	methods:
		login:
			interceptors: [
				trimmer ['login', 'password']
				validateRequest.get 'login', ['required', 'string']
				validateRequest.get 'password', ['required', 'string']
				validateRequest.get 'platform_type', ['required']
				validateRequest.enum 'platform_type', [PLATFORM_TYPE.ANDROID, PLATFORM_TYPE.IOS, PLATFORM_TYPE.WEB]
			]
			action: (data, user, session, req, res) ->
				Promise
					.resolve()
					.then -> User.findOne where: login: data.login
					.then (user) ->
						if not user
							return Promise.reject new CoreError ERROR_CODE.BAD_LOGIN_PASS
						return user

					.then (user) ->
						return User
							.checkPassword user, data.password
							.catch -> Promise.reject new CoreError ERROR_CODE.BAD_LOGIN_PASS

					.then (user) ->
						return Promise.all [
							Request.create user_id: user.id
							User.login user, data.platform_type
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


		logout:
			interceptors: [sessionInterceptor]
			action: (data, user, session) ->
				session
					.destroy()
					.then -> true
