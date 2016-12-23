ERROR_CODE = require 'app/modules/error_codes'

Sequelize = require 'sequelize'
sequelize = require 'app/sequelize'
socketIo = require 'app/modules/notification'

Session = sequelize.addModel 'session',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true

	user_id:
		type: Sequelize.UUID
		allowNull: true

	device_id:
		type: Sequelize.UUID
		allowNull: true
,
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


	classMethods:
		check: (sessionId) ->
			User = sequelize.models.User

			Session.findOne
				where: id: sessionId
				include: [
					model: Device
					as: 'Device'
				,
					model: User
					as: 'User'
				]

			.then (session) ->
				if not session or not session.User
					return Promise.reject ERROR_CODE.NOT_FOUND_USER

				return [session.User, session]


	links: (User, Session, Request) ->
		User.hasMany Session,
			as: 'Sessions'
			foreignKey: 'user_id'

		Session.belongsTo User,
			as: 'User'
			foreignKey: 'user_id'

		Request.belongsTo Session,
			as: 'Session'
			foreignKey: 'session_id'

		Session.hasMany Request,
			as: 'Requests'
			foreignKey: 'session_id'

module.export = Session
