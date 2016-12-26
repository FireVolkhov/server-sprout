Sequelize = require 'sequelize'
sequelize = require 'app/sequelize'

module.exports = sequelize.addModel 'request',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true

	date:
		type: Sequelize.DATE
		allowNull: false
		defaultValue: -> new Date()

	user_id:
		type: Sequelize.UUID
		allowNull: false

	session_id:
		type: Sequelize.UUID
		allowNull: true
,
	index: [
		fields: ['id']
		unique: true
	]
	links: (User, Session, Request) ->
		Request.belongsTo User,
			as: 'User'
			foreignKey: 'user_id'

		User.hasMany Request,
			as: 'Requests'
			foreignKey: 'user_id'

		Request.belongsTo Session,
			as: 'Session'
			foreignKey: 'session_id'

		Session.hasMany Request,
			as: 'Requests'
			foreignKey: 'session_id'
