module.exports =
	up: (queryInterface, Sequelize) ->
		queryInterface
			.createTable 'user',
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

			.then -> queryInterface.addIndex 'user', ['id', 'login'], unique: true
			.then -> queryInterface.addIndex 'user', ['login', 'password_hash']

	down: (queryInterface, Sequelize) ->
		queryInterface.dropTable 'user'
