module.exports =
	up: (queryInterface, Sequelize) ->
		query = queryInterface.sequelize.query.bind queryInterface.sequelize

		queryInterface
			.createTable 'device',
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
					type: Sequelize.STRING
					allowNull: false

				token:
					type: Sequelize.STRING 2048
					allowNull: true

			.then -> queryInterface.addIndex 'device', ['id'], unique: true
			.then ->
				query '''
            BEGIN;
              ALTER TABLE "device"
              ADD CONSTRAINT "device_user_id_fkey"
              FOREIGN KEY ("user_id") REFERENCES "user" ("id")
              MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL;

              ALTER TABLE "session"
							ADD CONSTRAINT "session_device_id_fkey"
							FOREIGN KEY ("device_id") REFERENCES "device" ("id")
							MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL;
            COMMIT;
						'''

			.catch (e) ->
				query 'ROLLBACK;'
				Promise.reject e

	down: (queryInterface, Sequelize) ->
		queryInterface.dropTable 'device'
