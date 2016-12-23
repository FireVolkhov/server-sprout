bcrypt = require 'bcrypt'
Sequelize = require 'sequelize'
sequelize = require 'app/sequelize'

User = sequelize.addModel 'user',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true
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
,
	index: [
			fields: ['id', 'login']
			unique: true
		,
			fields: ['login', 'password_hash']
	]

	instanceMethods:
		toSendFormat: ->
			# Только поля по апи
			id: @id
			name: @name


		login: (platformType, deviceId) ->
			{Session, Device} = sequelize.models

			return Device
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

				.then (session) =>
					Promise.all [this, session.save()]


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


		checkPassword: (pass) ->
			new Promise (resolve, reject) =>
				bcrypt.compare pass, @password_hash, (err, isValidPassword) ->
					if err
						return reject err
					else if isValidPassword
						return resolve this
					else
						return reject()


	classMethods:
		getDocExample: ->
			'''
				{
					"id": "login",
					"name": "Name"
				}
			'''

	hooks:
		beforeCreate: (user) ->
			user.passwordSet(user.password_hash)


	links: (User, Request) ->
		Request.belongsTo User,
			as: 'User'
			foreignKey: 'user_id'

		User.hasMany Request,
			as: 'Requests'
			foreignKey: 'user_id'

module.exports = User
