Sequelize = require 'sequelize'

PLATFORM_TYPE = require 'app/modules/users/const/platform_type'

sequelize = require 'app/sequelize'
User = require 'app/modules/users/models/user'
Session = require 'app/modules/users/models/session'

Device = sequelize.define 'device',
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
	timestamp: false
	createdAt: false
	updatedAt: false
	freezeTableName: true
	index: [
		fields: ['id']
		unique: true
	]

User.hasMany Device,
	as: 'Devices'
	foreignKey: 'user_id'

Device.belongsTo User,
	as: 'User'
	foreignKey: 'user_id'

module.exports = Device
