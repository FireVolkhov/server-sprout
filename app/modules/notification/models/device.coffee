PLATFORM_TYPE = require 'app/modules/users/const/platform_type'

Sequelize = require 'sequelize'
sequelize = require 'app/sequelize'

Device = sequelize.addModel 'device',
	id:
		type: Sequelize.UUID
		defaultValue: Sequelize.UUIDV4
		primaryKey: true

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

	links: (User, Device) ->
		User.hasMany Device,
			as: 'Devices'
			foreignKey: 'user_id'

		Device.belongsTo User,
			as: 'User'
			foreignKey: 'user_id'

module.exports = Device
