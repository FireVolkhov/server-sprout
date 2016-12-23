SESSION_TIMEOUT = require '../const/session_timeout'

should = require 'should'

tester = require 'app/test/tester'
usersActions = require 'app/modules/users/test/actions'
chatsActions = require 'app/modules/chats/test/actions'
adminChatsActions = require 'app/modules/chats/test/admin_actions'
workerActions = require 'app/modules/worker/test/admin_actions'
User = require 'app/modules/users/models/user'
Session = require 'app/modules/users/models/session'
Request = require 'app/modules/log/models/request'
Chat = require 'app/modules/chats/models/chat'
sequelize = require 'app/sequelize'

describe 'Сессии', ->
	io = null

	admin = null

	user1 = null
	user2 = null
	user3 = null
	user4 = null
	user5 = null
	user6 = null
	user6secondSession = null

	before ->
		@timeout 100000

		tester
			.initPromise
			.timeout 1000
			.then ->
				admin = tester.admin

				user1 = tester.users[0]
				user2 = tester.users[1]
				user3 = tester.users[2]
				user4 = tester.users[3]
				user5 = tester.users[4]

				User
					.findOne
						where:
							login: 'autotest6'

			.then (user) ->
				user6 = user
				user6._connectWithoutHeaders = user1._connectWithoutHeaders
				user6.connectWithoutHeaders = user1.connectWithoutHeaders

				user6secondSession = _.clone user
				user6secondSession._connectWithoutHeaders = user1._connectWithoutHeaders
				user6secondSession.connectWithoutHeaders = user1.connectWithoutHeaders

				user.online = false
				savePromise = user6.save()

				user.getChats()
					.then (results) -> _.uniqBy results, 'id'
					.then (chats) -> Promise.all _.map chats, (x) -> x.finish()
					.then -> savePromise

			.then -> Session.destroy where: user_id: user6.id
			.then -> Request.destroy where: user_id: user6.id

	after -> io?.disconnect()


#	describe 'Пушь нотификация', ->
#		@timeout 20000
#
#		user = null
#		chat = null
#
#		after ->
#			Promise.all [
#				if chat then chatsActions.finish user, chat_id: chat.id else null
#				if user then usersActions.logout user else null
#			]
#
#		it 'Если нет сокета отправляется пушь уведомление', ->
#			usersActions
#				.login
#					login: 'autotest6'
#					password: 'autotest6'
#					platform_type: 'ios'
#					device_id: 'Если нет сокета отправляется пушь уведомление'
#
#				.then ([u]) ->
#					user = u
#					usersActions.setPush user, push_token: '4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab'
#
#				.then ->
#					chatsActions
#						.edit user,
#							title: 'Если нет сокета отправляется пушь уведомление'
#							members: added_ids: [user1.id]
#
#				.then ([c]) ->
#					chat = c


	describe 'Сокет ио', ->
		@timeout 20000

		it 'Подключение без заголовков кикает сооединение через 5 сек', ->
			@timeout 10000
			return new Promise (resolve, reject) ->
				disconnectIsReject = true
				start = _.now()

				tester.users[0]._connectWithoutHeaders()
					.on 'disconnect', ->
						if disconnectIsReject
							reject new Error "Disconnect before 5 sec (#{_.now() - start})"
						else
							resolve()

				setTimeout ->
					disconnectIsReject = false
				, 5000

				setTimeout ->
					reject new Error 'Not disconnected'
				, 6000

		it 'Подключение без авторизации в заголовке', ->
			@timeout 15000

			localIo = null
			localUser = null

			usersActions.login
				login: 'autotest6'
				password: 'autotest6'
				platform_type: 'web'
				device_id: 'Приходят уведомления об изменении статуса пользователя'

			.then ([user]) ->
				localUser = tester.parseUser user

				return new Promise (resolve, reject) ->
					localUser.connectWithoutHeaders()
						.then (io) ->
							localIo = io

							io.on 'disconnect', (data) ->
								reject new Error data

						.catch (e) ->
							reject new Error e

					setTimeout ->
						resolve()
						localIo?.disconnect()
					, 2500

			.finally -> usersActions.logout localUser


		it 'Удаляем сессию и сокет у web если 30мин нет запросов', ->
			userWeb = null
			userAndroid = null

			Promise
			.all [
				usersActions.login
					login: 'autotest7'
					password: 'autotest7'
					platform_type: 'web'
					device_id: 'Удаляем сессию и сокет у web если 30мин нет запросов'
				usersActions.login
					login: 'autotest7'
					password: 'autotest7'
					platform_type: 'android'
					device_id: 'Удаляем сессию и сокет у web если 30мин нет запросов 2'
			]
			.then ([[uw], [ua]]) ->
				userWeb = uw
				userAndroid = ua

				Promise.all [
					Request
						.findOne
							where: session_id: userWeb.sessionId
							order: [['date', 'DESC']]
					Request
						.findOne
							where: session_id: userAndroid.sessionId
							order: [['date', 'DESC']]
				]

				.then ([webRequest, androidRequest]) ->
					webRequest.date = new Date(webRequest.date.getTime() - (SESSION_TIMEOUT * 2))
					androidRequest.date = new Date(androidRequest.date.getTime() - (SESSION_TIMEOUT * 2))
					Promise.all [
						webRequest.save()
						androidRequest.save()
					]

				.then -> workerActions.deleteOldSessions admin
				.then ->
					Promise.all [
						chatsActions.get userWeb, {}, false
						chatsActions.get userAndroid, {}, false
					]
				.then ([[webR, webRes], [androidR, androidRes]]) ->
					should(webRes.body).have.property 'error_code', 2
					should(webRes.body.error_message.length).above 0
					should(androidRes.body).have.property 'error_code', 0
					should(androidRes.body.error_message).be.null
