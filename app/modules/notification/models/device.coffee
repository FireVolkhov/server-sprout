PLATFORM_TYPE = require 'app/modules/users/const/platform_type'

Sequelize = require 'sequelize'
sequelize = require 'app/sequelize'

module.exports = sequelize.addModel 'device',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true

	user_id:
		type: Sequelize.UUID
		allowNull: true

	device_id:
		type: Sequelize.STRING 2048
		allowNull: false

	platform:
		type: Sequelize.ENUM PLATFORM_TYPE.ANDROID, PLATFORM_TYPE.IOS, PLATFORM_TYPE.WEB
		allowNull: false

	token:
		type: Sequelize.STRING 2048
		allowNull: true
,
	index: [
		fields: ['id']
		unique: true
	]

	links: (User, Session, Device) ->
		User.hasMany Device,
			as: 'Devices'
			foreignKey: 'user_id'

		Device.belongsTo User,
			as: 'User'
			foreignKey: 'user_id'

		Session.belongsTo Device,
			as: 'Device'
			foreignKey: 'device_id'
