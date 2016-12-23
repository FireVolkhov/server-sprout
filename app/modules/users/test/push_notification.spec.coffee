#should = require 'should'
#
#tester = require 'app/test/tester'
#usersActions = require 'app/modules/users/test/actions'
#chatsActions = require 'app/modules/chats/test/actions'
#messageActions = require 'app/modules/messages/test/actions'
#adminUsersActions = require 'app/modules/users/test/admin_actions'
#adminChatActions = require 'app/modules/chats/test/admin_actions'
#adminMessageActions = require 'app/modules/messages/test/admin_actions'
#
#User = require 'app/modules/users/models/user'
#Session = require 'app/modules/users/models/session'
#Request = require 'app/modules/log/models/request'
#Chat = require 'app/modules/chats/models/chat'
#sequelize = require 'app/sequelize'
#
#describe 'Push уведомления', ->
#	admin = null
#	user1 = null
#	user2 = null
#	user3 = null
#	user4 = null
#	user5 = null
#	user6 = null
#	user7 = null
#	user8 = null
#	user9 = null
#
#	before ->
#		@timeout 100000
#
#		clearUser = (user) ->
#			user._connectWithoutHeaders = user1._connectWithoutHeaders
#			user.connectWithoutHeaders = user1.connectWithoutHeaders
#
#			user.online = false
#			savePromise = user.save()
#
#			user.getChats()
#				.then (results) -> _.uniqBy results, 'id'
#				.then (chats) -> Promise.all _.map chats, (x) -> x.finish()
#				.then -> savePromise
#				.then -> Session.destroy where: user_id: user.id
#				.then -> Request.destroy where: user_id: user.id
#
#		tester
#			.initPromise
#			.then ->
#				admin = tester.admin
#				user1 = tester.users[0]
#				user2 = tester.users[1]
#				user3 = tester.users[2]
#				user4 = tester.users[3]
#				user5 = tester.users[4]
#
#				Promise.all [
#					User.findOne where: login: 'autotest6'
#					User.findOne where: login: 'autotest7'
#					User.findOne where: login: 'autotest8'
#					User.findOne where: login: 'autotest9'
#				]
#
#			.then ([_user6_, _user7_, _user8_, _user9_]) ->
#				user6 = _user6_
#				user7 = _user7_
#				user8 = _user8_
#				user9 = _user9_
#
#				Promise.all [
#					clearUser user6
#					clearUser user7
#					clearUser user8
#					clearUser user9
#				]
#
#		.then ->
#			adminUsersActions
#				.save admin,
#					id: user9.id
#					login: user9.login
#					name: 'Пользователь для автотестов 9'
#					last_name: 'Автотесты 9'
#					external_id: user9.login
#					web_version_status: 'all_address'
#					white_list: []
#					admin_privileges: false
#					is_blocked: true
#
#		.then -> true
#
#	after ->
#		adminUsersActions
#			.save admin,
#				id: user9.id
#				login: user9.login
#				name: 'Пользователь для автотестов 9'
#				last_name: 'Автотесты 9'
#				external_id: user9.login
#				web_version_status: 'all_address'
#				white_list: []
#				admin_privileges: false
#				is_blocked: false
#
#			.then -> true
#
#	describe 'Отправляються если нет сокета для конкретного девайса', ->
#		iosDevice = 'user6-ios-test-device'
#		iosToken = 'user6-ios-test-token'
#		iosDeviceTwo = 'user6-ios-test-device-two'
#		iosTokenTwo = 'user6-ios-test-token-two'
#		localUser6 = null
#		localUser6Two = null
#		io6 = null
#
#		androidDevice = 'user7-android-test-device'
#		androidToken = 'user7-android-test-token'
#		androidDeviceTwo = 'user7-android-test-device-two'
#		androidTokenTwo = 'user7-android-test-token-two'
#		localUser7 = null
#		localUser7Two = null
#		io7 = null
#
#		androidDeviceUser8 = 'user8-android-test-device'
#		androidTokenUser8 = 'user8-android-test-token'
#		androidDeviceUser8Two = 'user8-android-test-device-two'
#		androidTokenUser8Two = 'user8-android-test-token-two'
#		localUser8 = null
#		localUser8Two = null
#		io8 = null
#
#		iosDeviceUser9 = 'user9-ios-test-device'
#		iosTokenUser9 = 'user9-ios-test-token'
#		iosDeviceUser9Two = 'user9-ios-test-device-two'
#		iosTokenUser9Two = 'user9-ios-test-token-two'
#		localUser9 = null
#		localUser9Two = null
#		io9 = null
#
#		localChat = null
#
#		it 'Пользователю пришло новое сообщение', ->
#			@timeout 100000
#
#			Promise
#				.all [
#					usersActions
#						.login
#							login: 'autotest6'
#							password: 'autotest6'
#							platform_type: 'ios'
#							device_id: iosDevice
#					usersActions
#						.login
#							login: 'autotest6'
#							password: 'autotest6'
#							platform_type: 'ios'
#							device_id: iosDeviceTwo
#					usersActions
#						.login
#							login: 'autotest7'
#							password: 'autotest7'
#							platform_type: 'android'
#							device_id: androidDevice
#					usersActions
#						.login
#							login: 'autotest7'
#							password: 'autotest7'
#							platform_type: 'android'
#							device_id: androidDeviceTwo
#					usersActions
#						.login
#							login: 'autotest8'
#							password: 'autotest8'
#							platform_type: 'android'
#							device_id: androidDeviceUser8
#					usersActions
#						.login
#							login: 'autotest8'
#							password: 'autotest8'
#							platform_type: 'android'
#							device_id: androidDeviceUser8Two
#					usersActions
#						.login
#								login: 'autotest9'
#								password: 'autotest9'
#								platform_type: 'ios'
#								device_id: iosDeviceUser9
#					usersActions
#						.login
#								login: 'autotest9'
#								password: 'autotest9'
#								platform_type: 'ios'
#								device_id: iosDeviceUser9Two
#				]
#
#				.then ([[u6], [u6Two], [u7], [u7Two], [u8], [u8Two], [u9], [u9Two]]) ->
#					localUser6 = tester.parseUser u6
#					localUser7 = tester.parseUser u7
#					localUser8 = tester.parseUser u8
#					localUser9 = tester.parseUser u9
#
#					localUser6Two = tester.parseUser u6Two
#					localUser7Two = tester.parseUser u7Two
#					localUser8Two = tester.parseUser u8Two
#					localUser9Two = tester.parseUser u9Two
#
#					localUser6Two.connectWithoutHeaders()
#						.then (_io_) -> io6 = _io_
#
#					localUser7Two.connectWithoutHeaders()
#						.then (_io_) -> io7 = _io_
#
#					localUser8Two.connectWithoutHeaders()
#						.then (_io_) -> io8 = _io_
#
#					localUser9Two.connectWithoutHeaders()
#						.then (_io_) -> io9 = _io_
#
#				.then ->
#					Promise.all [
#						usersActions.setPush localUser6, push_token: iosToken
#						usersActions.setPush localUser6Two, push_token: iosTokenTwo
#						usersActions.setPush localUser7, push_token: androidToken
#						usersActions.setPush localUser7Two, push_token: androidTokenTwo
#						usersActions.setPush localUser8, push_token: androidTokenUser8
#						usersActions.setPush localUser8Two, push_token: androidTokenUser8Two
#						usersActions.setPush localUser9, push_token: iosTokenUser9
#						usersActions.setPush localUser9Two, push_token: iosTokenUser9Two
#					]
#
#				.then ->
#					Promise.all [
#						chatsActions
#							.edit localUser6,
#								members: added_ids: [user7.external_id]
#								observers: added_ids: [user8.external_id]
#							.then ([c]) -> localChat = c
#						tester.mustNotHavePushNotification iosToken
#						tester.mustNotHavePushNotification iosTokenTwo
#						tester.mustHavePushNotification androidToken
#						tester.mustNotHavePushNotification androidTokenTwo
#						tester.mustNotHavePushNotification androidTokenUser8
#						tester.mustNotHavePushNotification androidTokenUser8Two
#						tester.mustNotHavePushNotification iosTokenUser9
#						tester.mustNotHavePushNotification iosTokenUser9Two
#					]
#
#				.then ->
#					Promise.all [
#						messageActions.send localUser6Two,
#							chat_id: localChat.id
#							text: 'test'
#							client_id: '00000000-0000-0000-0000-000000000000'
#						tester.mustNotHavePushNotification iosToken
#						tester.mustNotHavePushNotification iosTokenTwo
#						tester.mustHavePushNotification androidToken
#						tester.mustNotHavePushNotification androidTokenTwo
#						tester.mustNotHavePushNotification androidTokenUser8
#						tester.mustNotHavePushNotification androidTokenUser8Two
#						tester.mustNotHavePushNotification iosTokenUser9
#						tester.mustNotHavePushNotification iosTokenUser9Two
#					]
#
#		it 'Создатель запросил метод chat/notify. Push-нотификация приходит наблюдателям и участникамчата', ->
#			@timeout 10000
#			Promise.all [
#				chatsActions.done localUser6Two, chat_id: localChat.id
#				tester.mustNotHavePushNotification iosToken
#				tester.mustNotHavePushNotification iosTokenTwo
#				tester.mustHavePushNotification androidToken
#				tester.mustNotHavePushNotification androidTokenTwo
#				tester.mustHavePushNotification androidTokenUser8
#				tester.mustNotHavePushNotification androidTokenUser8Two
#				tester.mustNotHavePushNotification iosTokenUser9
#				tester.mustNotHavePushNotification iosTokenUser9Two
#			]
#
#		it 'Если наблюдатель запросил метод chat/accept. Push-нотификация приходит создателю.', ->
#			@timeout 10000
#			Promise
#				.all [
#					chatsActions.accept localUser8Two, chat_id: localChat.id
#					tester.mustHavePushNotification iosToken
#					tester.mustNotHavePushNotification iosTokenTwo
#					tester.mustNotHavePushNotification androidToken
#					tester.mustNotHavePushNotification androidTokenTwo
#					tester.mustNotHavePushNotification androidTokenUser8
#					tester.mustNotHavePushNotification androidTokenUser8Two
#					tester.mustNotHavePushNotification iosTokenUser9
#					tester.mustNotHavePushNotification iosTokenUser9Two
#				]
#
#				.finally ->
#					if localChat
#						chatsActions.finish localUser6Two, chat_id: localChat.id
#
#		it 'Администратор восстановил чат. Push-нотификация приходит всем пользователям, которых он указал', ->
#			@timeout 10000
#
#			restoredChat = null
#
#			adminMessageActions
#				.get admin, chat_id: localChat.id
#				.then ([messages]) ->
#					Promise.all [
#						adminChatActions
#							.restore admin,
#								chat_id: localChat.id
#								user_ids: [user6.external_id]
#								message_ids: _.map messages, (x) -> x.id
#							.then ([chat]) -> restoredChat = chat
#						tester.mustHavePushNotification iosToken
#						tester.mustNotHavePushNotification iosTokenTwo
#						tester.mustNotHavePushNotification androidToken
#						tester.mustNotHavePushNotification androidTokenTwo
#						tester.mustNotHavePushNotification androidTokenUser8
#						tester.mustNotHavePushNotification androidTokenUser8Two
#						tester.mustNotHavePushNotification iosTokenUser9
#						tester.mustNotHavePushNotification iosTokenUser9Two
#					]
#
#				.finally ->
#					if restoredChat
#						chatsActions.finish localUser6Two, chat_id: restoredChat.id
#
#		it 'logout стирает девайс из бд', ->
#			@timeout 10000
#
#			localChat = null
#
#			chatsActions
#				.edit localUser6,
#					members: added_ids: [user7.external_id]
#					observers: added_ids: [user8.external_id]
#
#				.then ([chat]) ->
#					localChat = chat
#
#					Promise.all [
#						messageActions.send localUser6Two,
#							chat_id: localChat.id
#							text: 'test'
#							client_id: '00000000-0000-0000-0000-000000000000'
#						tester.mustNotHavePushNotification iosToken
#						tester.mustNotHavePushNotification iosTokenTwo
#						tester.mustHavePushNotification androidToken
#						tester.mustNotHavePushNotification androidTokenTwo
#						tester.mustNotHavePushNotification androidTokenUser8
#						tester.mustNotHavePushNotification androidTokenUser8Two
#						tester.mustNotHavePushNotification iosTokenUser9
#						tester.mustNotHavePushNotification iosTokenUser9Two
#					]
#
#				.then -> usersActions.logout localUser7
#				.then ->
#					Promise.all [
#						messageActions.send localUser6Two,
#							chat_id: localChat.id
#							text: 'test'
#							client_id: '00000000-0000-0000-0000-000000000000'
#						tester.mustNotHavePushNotification iosToken
#						tester.mustNotHavePushNotification iosTokenTwo
#						tester.mustNotHavePushNotification androidToken
#						tester.mustNotHavePushNotification androidTokenTwo
#						tester.mustNotHavePushNotification androidTokenUser8
#						tester.mustNotHavePushNotification androidTokenUser8Two
#						tester.mustNotHavePushNotification iosTokenUser9
#						tester.mustNotHavePushNotification iosTokenUser9Two
#					]
#
#				.finally ->
#					io6?.disconnect()
#					io7?.disconnect()
#					io8?.disconnect()
#					io9?.disconnect()
#
#					if localChat
#						chatsActions.finish localUser6Two, chat_id: localChat.id
