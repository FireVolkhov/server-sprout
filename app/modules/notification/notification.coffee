PLATFORM_TYPE = require 'app/modules/users/const/platform_type'
REDIS_VARIABLE = require 'app/modules/users/const/redis_variable'

redis = require 'app/redis'
socketIo = require 'app/socket_io'
pushNotification = require 'app/push_notification'
worker = require 'app/worker'
sequelize = require 'app/sequelize'

Logger = require 'app/core/Logger'

service =
	###
		Уведомление о том, что надо разблокировать пользователя

		Название поля 		Тип поля 	Описание 													Обязательность
		error 						object 		Сообщение в popup 								Да
	###
	userLogout: (users, data, needSendPushToUsers) -> @send users, 'notification/logout', data, needSendPushToUsers

	sendLogger: new Logger 'notification/send'
	emitLogger: new Logger 'notification/socket_io/emit'
	disconnectLogger: new Logger 'notification/socket_io/disconnect'
	pushLogger: new Logger 'notification/push'

	send: (users = [], event, data, needSendPushToUsers = []) ->
		{Device} = sequelize.models

		if needSendPushToUsers and not _.isArray(needSendPushToUsers)
			needSendPushToUsers = [needSendPushToUsers]

		Promise
			.resolve users
			.then (users) =>
				if users and not _.isArray(users)
					users = [users]

				if users.length is 0
					return

				Promise
					.all _.map users, (x) =>
						Promise
							.all [x, x.getSessions(), Device.findAll(where: user_id: x.id)]
							.then ([user, sessions, devices]) =>
								sessions =
									Promise.all _.map sessions, (x) =>
										@hasSessionSocket x
											.then (session) -> if session then x

								return Promise.all [user, sessions, devices]

							.then ([user, sessions, devices]) =>
								result =
									user: user
									socketSessions: _.compact(sessions)
									pushDevices: []

								# Только для девайсов указанных пользователей
								if _.find(needSendPushToUsers, (x) -> x.id is user.id)

									# Только для девайсов без сокета
									result.pushDevices = _.filter devices, (x) -> not _.find result.socketSessions, (y) -> y.device_id is x.id

									# Только для девайсов с токеном
									result.pushDevices = _.filter result.pushDevices, (x) -> x.token

								return result

					.then (results) =>
						pushUsers = []
						pushDevices = []

						socketUsers = []
						socketSessions = []

						_.each results, (x) ->
							pushDevices = pushDevices.concat x.pushDevices
							socketSessions = socketSessions.concat x.socketSessions

							if x.pushDevices.length
								pushUsers.push x.user

							if x.socketSessions.length
								socketUsers.push x.user
							return

						Promise.all [@_sendPush(pushUsers, pushDevices), @_sendSocket(socketUsers, socketSessions, event, data)]

			.catch (error) =>
				stack = error?.stack or error
				console.error stack
				@sendLogger.error stack
				Promise.reject error


	hasSessionSocket: (session) ->
		redis
			.getList REDIS_VARIABLE.SESSIONS_ROOMS
			.then ([range]) ->
				redisRoom = !!(_.find range, (x) -> x is session?.id) or 0
				hasSession = _.keys(socketIo.lastVersion.sockets.adapter.rooms[session?.id]?.sockets)?.length or 0

				return !!(redisRoom) or !!(hasSession)

	hasSessionsSocket: (sessions) ->
		Promise.all _.map sessions, (x) => @hasSessionSocket x
			.then (sessions) -> !!_.compact(sessions).length

	isUserHaveSocket: (user) ->
		user
			.getSessions()
			.then (sessions) => @hasSessionsSocket sessions

	disconnect: (sessionsPromise, options = true) ->
		Promise
			.resolve sessionsPromise
			.then (sessions) =>
				_.each sessions, (session) =>
					# На всякий случай сильно смахивает на костыль
					try
						if (id = _.keys(socketIo.lastVersion.sockets.adapter.rooms[session.id]?.sockets)?[0])
							socketIo.lastVersion.sockets.sockets[id]?.disconnect options

					catch error
						console.error error.stack
						@disconnectLogger.error error.stack

					return


	_sendSocket: (users, sessions, event, dataPromise) ->
		if not users.length or not sessions.length
			return

		Promise
			.all [sessions, dataPromise]
			.then ([sessions, data]) =>
				@emitLogger.log """\n
					event: #{event}
					users: #{JSON.stringify _.map users, (x) -> x.login}
					data: #{JSON.stringify data}
					sessions: #{sessions.length}
					\n
				"""
				console.log "Socket event `#{event}` to `#{JSON.stringify _.map(users, (x) -> x.login)}`"

				_.each sessions, (session) =>
					if event in ['notification/logout']
						response =
							result: null
							error_message: data.error.MESSAGE
							error_code: data.error.CODE
					else
						response =
							result: data
							error_message: null
							error_code: 0

					socketIo.lastVersion.emitter
						.to session.session.id
						.emit event, response

			.catch (error) =>
				error = error?.stack or error
				console.error error
				@emitLogger.error error

	_sendPush: (users, devices) ->
		Promise
			.resolve()
			.then =>
				if not users.length or not devices.length
					return

				message =
					title: 'New message in chat'

				tokens = {}
				tokens[PLATFORM_TYPE.ANDROID] = []
				tokens[PLATFORM_TYPE.IOS] = []
				tokens[PLATFORM_TYPE.WEB] = []

				_.each devices, (x) ->
					tokens[x.platform]?.push x.token
					return

				@pushLogger.log """\n
					users: #{JSON.stringify _.map users, (x) -> x.login}
					devices: #{JSON.stringify _.map devices, (x) -> x.deviceId}
					tokens:
						android: #{tokens[PLATFORM_TYPE.ANDROID]}
						ios: #{tokens[PLATFORM_TYPE.IOS]}
						web: #{tokens[PLATFORM_TYPE.WEB]}
					\n
				"""
				console.log "Push event to `#{JSON.stringify _.map(users, (x) -> x.login)}` tokens: `#{JSON.stringify tokens}`"
				pushNotification.send tokens, message

			.catch (error) =>
				error = error?.stack or error
				console.error error
				@sendLogger.error error

module.exports = service

# Чистим лист комнат в redis если делаем рестарт сервера в админской ноде
#if configGetter.onAdminSection
#	Promise.all [
#		redis.clearList REDIS_VARIABLE.SESSIONS_ROOMS
#		redis.clearList REDIS_VARIABLE.DISCONNECTS
#		redis.delKey REDIS_VARIABLE.LINKS
#		redis.delKey REDIS_VARIABLE.MESSAGES
#	]

# Такска для тестов нотификации
worker.registerTask
	name: 'sendPush'
	action: ->
		User = require 'app/modules/users/models/user'
		Session = require 'app/modules/users/models/session'
		User
			.findOne where: login: 'autotest2'
			.then (user) ->
				Session
					.destroy where: user_id: user.id
					.then -> user

			.then (user) -> service.newMessage user, {}, user
			.timeout 2000

#		tokens[PLATFORM_TYPE.ANDROID]
#			'c45yiEELI-w:APA91bHPQ2lEgM6kOQpOy4NnArKQdQLnMm4Hb4ZVfAS3FJXjf0owgVrko19xBeyE9G759jN18z1uS6Dh7eszleM2k4LsovEq9J-GUuc04lLLhyzTFskQ-UvQJ7LMpQkxxyY3ZnwLNfwJ'
#			'ckWUc-XxaTE:APA91bF4VmDUYSoXqAFJtz6dEZLWhkn0YubFQoT55CEgmn_vswzLCeuYyZ17m4noK_8w957lH0Y0rG42IVzi1nMq2P3dT0ivpYhBfQFbi04FUhUORKAZH6aoWYIJIw77al0dOPKjVq1a'
#		tokens[PLATFORM_TYPE.IOS]
#			'663324592db76a28b0b0967d1b1e940e6d23b57af8b0bd6057dd1e84be6859f4'
#			'ef0e83fd16578a8e04fe4f6ecc7d54a9cb440fcd96ba0e5ca61d6af4ef8913c3'
