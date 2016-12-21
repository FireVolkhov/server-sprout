Sequelize = require 'sequelize'
bcrypt = require 'bcrypt'

GOD_MODE_ON = '7f884e8d-552b-40c3-b984-61277aee281c'
WEB_VERSION_STATUS = require 'app/modules/users/const/web_version_status'
MAX_REQUEST = require 'app/modules/log/const/max_request'
#CHAT_STATUS = require 'app/modules/chats/const/chat_status'

sequelize = require 'app/sequelize'
#common = require 'app/modules/common'
socketIo = require 'app/modules/notification'

#RSAKey = require 'app/modules/encryption/models/key'
Request = require 'app/modules/log/models/request'
#Bluetooth = require './bluetooth'

module.exports = User = sequelize.define 'user',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true
		unique: true

	external_id:
		type: Sequelize.STRING 255
		allowNull: false
		unique: true

	login:
		type: Sequelize.STRING
		allowNull: false
		unique: true

	password_hash:
		type: Sequelize.STRING
		allowNull: false

	name:
		type: Sequelize.STRING
		allowNull: false

	last_name:
		type: Sequelize.STRING
		allowNull: true

	color:
		type: Sequelize.STRING
		allowNull: false

	is_blocked:
		type: Sequelize.BOOLEAN
		allowNull: false
		defaultValue: false

	online:
		type: Sequelize.BOOLEAN
		defaultValue: false
		allowNull: false

	web_access:
		type: Sequelize.ENUM(
			WEB_VERSION_STATUS.OFF,
			WEB_VERSION_STATUS.ALL_ADDRESS,
			WEB_VERSION_STATUS.WHITE_LIST
		)
		allowNull: false
		defaultValue: WEB_VERSION_STATUS.ALL_ADDRESS

	is_admin:
		type: Sequelize.BOOLEAN
		defaultValue: false
		allowNull: false

	is_use_i_beacon:
		type: Sequelize.BOOLEAN
		allowNull: false
		defaultValue: true
,
	timestamp: false
	createdAt: false
	updatedAt: false
	freezeTableName: true
	index: [
			fields: ['id', 'name', 'external_id']
			unique: true
		,
			fields: ['login', 'password_hash']
	]

	defaultScope:
		include: [
			model: Request
			as: 'Requests'
			order: [['date', 'DESC']]
			limit: 1
			separate: true
#		,
#			model: Bluetooth
#			as: 'Bluetooth'
		]

	instanceMethods:
		toSendFormat: ->
			# Только поля по апи
			id: @external_id
			name: @name
			color: @color
			online: @online
			last_date_online: if @online then new Date() else (@Requests[0]?.date or null)

		toSendAdminFormat: ->
			@getIPs()
				.then (ips) =>
					id: @id
					login: @login
					external_id: @external_id
					name: @name
					last_name: @last_name
					password: null
					color: @color
					online: @online
					last_date_online: if @online then new Date() else (@Requests[0]?.date or null)
					web_version_status: @web_access
					admin_privileges: @is_admin
					white_list: _.map ips, (x) -> x.address
					is_blocked: !!@is_blocked
					is_use_i_beacon: @is_use_i_beacon
#					i_beacon:
#						uuid: @Bluetooth?.uuid or null
#						minor: @Bluetooth?.minor or null
#						major: @Bluetooth?.major or null

		getAllChats: (options = {}) ->
			options.where ?= {}
			whereForCreator = _.clone options.where
			whereForCreator.$or = status: CHAT_STATUS.ACTIVE

			options.where.finishedAt = null

			creatorRequest =
				where: whereForCreator
				include: options.include
			creatorRequest.where.creator = @id

			membersRequest =
				where: _.clone options.where
				include: options.include
			membersRequest.where.doneAt = null

			observersRequest =
				where: _.clone options.where
				include: options.include

			observersRequest.where.doneAt =
				$not: null

			Promise.resolve @getChats()

		getAllChatsCanSendMessage: (options = {}) ->
			Chat = require 'app/modules/chats/models/chat'

			if not options.where
				options.where = {}

			options.where.finishedAt = null

			creatorRequest =
				where: _.clone options.where
				include: options.include
			creatorRequest.where.creator = @id
			creatorRequest.where.doneAt = null

			membersRequest =
				where: _.clone options.where
				include: options.include
			membersRequest.where.doneAt = null

			Promise
				.all [Chat.findAll(creatorRequest), @getChatsWhenMember(membersRequest)]
				.then (results) ->
					items = [].concat results[0], results[1]
					items = _.uniqBy items, 'id'

		block: (value) ->
			@is_blocked = !!value

			Promise.all [
				@save()
				socketIo.disconnect @getSessions()
					.then (session) -> _.each session, (x) -> x.destroy()
			]

			.then -> true

		isHaveManyRequest: (godModeKey) ->
			Request = require 'app/modules/log/models/request'

			Request
				.findAll
					where:
						user_id: @id
						date: $gt: new Date(new Date().getTime() - MAX_REQUEST.BLOCK_TIME)
					order: 'date'

			.then (requests) =>
				results = {}

				_.each requests, (r) ->
					results[r.id] = []

					_.each results, (x) ->
						if x.length <= MAX_REQUEST.COUNT
							x.push r
						return
					return

				found = _.find results, (x) ->
					(start = x[0]?.date.getTime()) and (end = x[MAX_REQUEST.COUNT]?.date.getTime()) and (end - start) < MAX_REQUEST.TIMEOUT

				if found and godModeKey isnt GOD_MODE_ON
					return socketIo
						.disconnect @getSessions()
						.then -> true

				return false

		setOnline: (bool) ->
			if @online is bool
				return Promise.resolve this

			@online = bool

			usersPromise = @getChats
					include: [
						model: User
						as: 'Users'
						through: where: is_visible: true
					]
				,
					where: is_visible: true

			.then (chats) =>
				result = _.map chats, (x) -> x.Users
				users = _.uniq [].concat.apply([], result), 'id'
				users = _.filter users, (x) -> x.id isnt @id

			return Promise
				.all [
					@save()
					socketIo.userOnline usersPromise,
						user_id: @external_id
						online: @online
				]
				.then => this


		passwordSet: (password) ->
			new Promise (resolve, reject) =>
				bcrypt.genSalt 10, (err, salt) =>
					if err
						reject err

					bcrypt.hash password, salt, (err, hash) =>
						if err
							reject err

						@password_hash = hash
						resolve this
				return

		isAllowIP: (ip) ->
			switch @web_access
				when WEB_VERSION_STATUS.OFF then false
				when WEB_VERSION_STATUS.ALL_ADDRESS
					if ip
						IP = require './ip'
						IP
							.findOne
								where:
									user_id: @id
									address: ip

							.then (ipModel) =>
								if not ipModel
									IP.create
										user_id: @id
										address: ip

							.catch (e) -> console.error e.stack

					return true
				when WEB_VERSION_STATUS.WHITE_LIST then !!_.find @IPs, (x) -> x.address is ip


	classMethods:
		checkPassword: (user, pass) ->
			new Promise (resolve, reject) =>
				bcrypt.compare pass, user.password_hash, (err, isValidPassword) ->
					if err
						return reject err
					else if isValidPassword
						return resolve user
					else
						return reject()

		login: (user, platformType, deviceId, publicKey) ->
			Session = require './session'
			Device = require 'app/modules/notification/models/device'

			sessionPromise = Device
			.findOne where: device_id: deviceId
			.then (device) ->
				if device
					device.user_id = user.id

					Promise
						.all [
							device.save()
							Session.destroy where: device_id: device.id
						]

					.then ([device]) -> device

				else
					Device.create
						user_id: user.id
						device_id: deviceId
						platform: platformType

			.then (device) ->
				Session
				.create
					user_id: user.id
					device_id: device.id

			Promise
				.all [
					RSAKey.create public: publicKey
					RSAKey.createKey()
					sessionPromise
				]
				.then ([clientKey, serverKey, session]) ->
					session.client_key_id = clientKey.id
					session.server_key_id = serverKey.id

					Promise.all [user, session.save(), clientKey, serverKey]


		getDocExample: ->
			'''
				{
					"id": "login",
					"name": "Name",
					"color": "#835C1C",
					"online": true,
					"last_date_online": "2016-09-16T07:29:28.093Z"
				}
			'''

		getDocExampleForAdmin: ->
			'''
				{
					"id": "123e4567-e89b-12d3-a456-426655440000",
					"external_id": "login",
					"name": "string",
					"last_name": null,                               // null or string
					"password": null,
					"color": "#835C1C",
					"online": false,
					"last_date_online": "2016-09-16T07:29:28.093Z",
					"web_version_status": "all_address",             // "off" or "all_address" or "white_list"
					"admin_privileges": false,
					"white_list": ["192.168.11.14"],
					"is_blocked": false,
					"is_use_i_beacon": true
					"i_beacon":
					{
						"uuid": "123e4567-e89b-12d3-a456-426655440000",
						"minor": "65535",
						"major": "65535"
					}
				}
			'''

	hooks:
		beforeValidate: (user) ->
			if not user.color
				user.color = common.colorGenerator.getRandomColor()

			if not user.external_id
				user.external_id = user.login

			return user

		beforeCreate: (user) ->
			user.passwordSet(user.password_hash)


Request.belongsTo User,
	as: 'User'
	foreignKey: 'user_id'

User.hasMany Request,
	as: 'Requests'
	foreignKey: 'user_id'

#Bluetooth.belongsTo User,
#	as: 'User'
#	foreignKey: 'user_id'

#User.hasOne Bluetooth,
#	as: 'Bluetooth'
#	foreignKey: 'user_id'

worker = require 'app/worker'

worker.registerTask
	name: 'createDefaultAdmin'
	action: ->
		User
		.find where: login: 'admin'
		.then (admin) ->
			if admin
				return admin
			else
				return User
				.create
					name: 'Admin'
					login: 'admin'
					password: 'admin'

		.then (admin) -> admin.passwordSet 'admin'
		.then (admin) ->
			admin.is_admin = true
			admin.save()

		.then -> true
