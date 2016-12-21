Sequelize = require 'sequelize'

ERROR_CODE = require 'app/modules/error_codes'
PLATFORM_TYPE = require '../const/platform_type'
SESSION_TIMEOUT = require '../const/session_timeout'

sequelize = require 'app/sequelize'
worker = require 'app/worker'
socketIo = require 'app/modules/notification'
User = require './user'
#IP = require './ip'
#Device = require 'app/modules/notification/models/device'
Request = require 'app/modules/log/models/request'

Session = sequelize.define 'session',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true

	user_id:
		type: Sequelize.UUID
		allowNull: true

	client_key_id:
		type: Sequelize.UUID
		allowNull: true

	server_key_id:
		type: Sequelize.UUID
		allowNull: true

	device_id:
		type: Sequelize.UUID
		allowNull: true
,
	timestamp: false
	createdAt: false
	updatedAt: false
	freezeTableName: true
	index: [
		fields: ['id']
		unique: true
	]

	hooks:
		beforeDestroy: (model) ->
			if _.isArray(model)
				sessions = model
			else
				sessions = [model]

			socketIo.disconnect sessions
			return

		afterDestroy: (model) ->
			model.getServerKey().then (key) -> key?.destroy()
			model.getClientKey().then (key) -> key?.destroy()

			return model


	classMethods:
		check: (id, ip) ->
			return Promise
				.resolve id
				.then (sessionId) ->
					Session.findOne
						where:
							id: sessionId
						include: [
							model: Device
							as: 'Device'
						,
							model: User
							as: 'User'
							include: [
								model: IP
								as: 'IPs'
							]
						]

				.then (session) ->
					if session
						return Promise.all [session.User, session, session.getServerKey(), session.getClientKey()]
					else
						return Promise.reject ERROR_CODE.NOT_FOUND_USER

				.then ([user, session, serverKey, clientKey]) ->
					if not user
						return Promise.reject ERROR_CODE.NOT_FOUND_USER

					if session.Device.platform is PLATFORM_TYPE.WEB and not user.isAllowIP(ip)
						session.destroy()
						return Promise.reject ERROR_CODE.WEB_BLOCKED

					return [user, session, serverKey, clientKey]

				.catch (e) ->
					if e.stack
						console.error e.stack
					return Promise.reject e

User.hasMany Session,
	as: 'Sessions'
	foreignKey: 'user_id'

Session.belongsTo User,
	as: 'User'
	foreignKey: 'user_id'

#RSAKey.hasOne Session,
#	as: 'Session'
#	foreignKey: 'client_key_id'

#Session.belongsTo RSAKey,
#	as: 'ClientKey'
#	foreignKey: 'client_key_id'

#RSAKey.hasOne Session,
#	as: 'Session'
#	foreignKey: 'server_key_id'

#Session.belongsTo RSAKey,
#	as: 'ServerKey'
#	foreignKey: 'server_key_id'

#Session.belongsTo Device,
#	as: 'Device'
#	foreignKey: 'device_id'

Request.belongsTo Session,
	as: 'Session'
	foreignKey: 'session_id'

Session.hasMany Request,
	as: 'Requests'
	foreignKey: 'session_id'

module.exports = Session
