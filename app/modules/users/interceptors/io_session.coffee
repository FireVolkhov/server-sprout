colors = require 'colors/safe'

SESSION_SOCKET_CONNECT_TIMEOUT = require './../const/session_socket_connect_timeout'
SESSION_INACTIVE_TIMEOUT = require '../const/session_inactive_timeout'
PLATFORM_TYPE = require 'app/modules/users/const/platform_type'
REDIS_VARIABLE = require 'app/modules/users/const/redis_variable'

sequelize = require 'app/sequelize'

socketIo = require 'app/modules/notification'
redis = require 'app/redis'

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
	socketIo.hasSessionSocket session_id
		.then (isHave) ->
			if not isHave
				redis.remInRoom REDIS_VARIABLE.DISCONNECTS, session_id

checkSession = (socket, sessionId) ->
	{Session} = sequelize.models

	Session.check sessionId
		.then ([user, session]) ->
			socket.$user = user
			socket.$session = session

			return user

		.then (user) ->
			remRedisDisconnect sessionId
			socketIo.isUserHaveSocket user
				.then (isHave) ->
					Promise.all [
						redis.pushInRoom REDIS_VARIABLE.SESSIONS_ROOMS, sessionId
#						if not isHave then user.setOnline true
					]

				.then ->
					socket.join sessionId

			socket.on 'disconnect', ->
				addRedisDisconnect sessionId
				redis
					.remInRoom REDIS_VARIABLE.SESSIONS_ROOMS, sessionId
					.then -> socketIo.isUserHaveSocket user
					.then (isHave) -> if not isHave then user.setOnline false

				if socket.$session.Device.platform is PLATFORM_TYPE.WEB
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
						console.error error.stack

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

					checkSession socket, data?.session_id
						.then ->
							clearTimeout timer
							console.log colors.green('Connect successful'), socket.handshake

							if callback
								response =
									result: true
									error_message: null
									error_code: 0

								callback response
							resolve()

						.catch (error) ->
							if error?.stack
								console.error error.stack

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
