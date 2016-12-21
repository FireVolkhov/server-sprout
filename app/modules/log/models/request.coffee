Sequelize = require 'sequelize'

sequelize = require 'app/sequelize'

Request = sequelize.define 'request',
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
	timestamp: false
	createdAt: false
	updatedAt: false
	freezeTableName: true
	index: [
		fields: ['id']
		unique: true
	]

module.exports = Request
