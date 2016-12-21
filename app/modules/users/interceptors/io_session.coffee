colors = require 'colors/safe'
iconv = require 'iconv-lite'

ERROR_CODE = require 'app/core/const/error_codes'
SESSION_SOCKET_CONNECT_TIMEOUT = require './../const/session_socket_connect_timeout'
SESSION_INACTIVE_TIMEOUT = require '../const/session_inactive_timeout'
PLATFORM_TYPE = require 'app/modules/users/const/platform_type'
REDIS_VARIABLE = require 'app/modules/users/const/redis_variable'

Session = require '../models/session'

configGetter = require 'app/core/config_getter'
encryptionModule = require 'app/modules/encryption'
socketIo = require 'app/modules/notification'

addRedisDisconnect = (session_id) ->
	socketIo.getRedisList REDIS_VARIABLE.DISCONNECTS
		.then ([list]) ->
			if not (_.find list, (x) -> x is session_id)
				socketIo.pushRedisInRoom REDIS_VARIABLE.DISCONNECTS, session_id

checkRedisDisconnect = (session_id) ->
	socketIo.getRedisList REDIS_VARIABLE.DISCONNECTS
		.then ([list]) -> return !!(_.find list, (x) -> x is session_id)

remRedisDisconnect = (session_id) ->
	socketIo.hasSessionSocket session_id
		.then (isHave) ->
			if not isHave
				socketIo.remRedisInRoom REDIS_VARIABLE.DISCONNECTS, session_id

checkSession = (socket, sessionId) ->
	ip = socket.conn.remoteAddress?.trim()

	Session.check sessionId, ip
		.then ([user, session, serverKey, clientKey]) ->
			socket.$CurrentUser = user
			socket.$CurrentSession = session
			socket.$CurrentServerRSAKey = serverKey
			socket.$CurrentClientRSAKey = clientKey

			return user

		.then (user) ->
			remRedisDisconnect sessionId
			socketIo.isUserHaveSocket user
				.then (isHave) ->
					Promise.all [
						socketIo.pushRedisInRoom REDIS_VARIABLE.SESSIONS_ROOMS, sessionId
						if not isHave then user.setOnline true
					]

				.then ->
					socket.join sessionId

			socket.on 'disconnect', ->
				addRedisDisconnect sessionId
				socketIo.remRedisInRoom REDIS_VARIABLE.SESSIONS_ROOMS, sessionId
					.then -> socketIo.isUserHaveSocket user
					.then (isHave) -> if not isHave then user.setOnline false

				if socket.$CurrentSession.Device.platform is PLATFORM_TYPE.WEB
					setTimeout ->
						Session.findById sessionId
							.then (session) ->
								socketIo.hasSessionSocket session
									.then (isHave) ->
										if not isHave and checkRedisDisconnect(sessionId)
											Promise.all [
												remRedisDisconnect sessionId
												session?.destroy()
											]
					, SESSION_INACTIVE_TIMEOUT

module.exports =
	name: 'sessionInterceptor'
	priority: 100
	action: (io, socket, next) ->
		if (sessionId = socket.handshake.headers['x-session-id'])
			return checkSession socket, sessionId
				.then -> next()
				.catch (error) ->
					if error?.stack
						console.error error?.stack

					response =
						result: null
						error_message: error.MESSAGE
						error_code: error.CODE

					console.log colors.red('Disconnect because bad session'), socket.handshake
					socket.disconnect()

					setTimeout ->
						socket.disconnect true
					return Promise.reject response

		else
			socket.$loginPromise = new Promise (resolve, reject) ->
				timer = setTimeout ->
					console.log colors.red('Disconnect because not have request for one second'), socket.handshake
					socket.disconnect()

					setTimeout ->
						socket.disconnect true
					reject 'Timeout disconnect'
				, SESSION_SOCKET_CONNECT_TIMEOUT

				socket.on 'user/subscribe', (data, callback) ->
					console.log colors.yellow('Call socket event `user/subscribe`'), arguments

					Promise
						.resolve()
						.then ->
							if configGetter.withEncryption
								try
									data = JSON.parse encryptionModule.decrypt data, encryptionModule.serverKey

								catch e
									return Promise.reject e

						.then -> checkSession socket, data?.session_id
						.then ->
							clearTimeout timer
							console.log colors.green('Connect successful'), socket.handshake

							if callback
								response =
									result: true
									error_message: null
									error_code: 0

								if configGetter.withEncryption
									response = encryptionModule.encrypt response, socket.$CurrentClientRSAKey

								callback response
							resolve()

						.catch (error) ->
							if error?.stack
								console.error error?.stack

							clearTimeout timer
							console.log colors.red('Disconnect because bad session'), socket.handshake
							socket.disconnect()

							setTimeout ->
								socket.disconnect true

							callback?(
								result: false
								error_message: error?.stack or null
								error_code: 0
							)
							reject 'Bad authorization disconnect'

			return next()
