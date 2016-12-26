module.exports =
	up: (queryInterface, Sequelize) ->
		query = queryInterface.sequelize.query.bind queryInterface.sequelize

		queryInterface
			.createTable 'session',
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

			.then -> queryInterface.addIndex 'session', ['id'], unique: true
			.then ->
				query '''
						BEGIN;
							ALTER TABLE "session"
							ADD CONSTRAINT "session_user_id_fkey"
							FOREIGN KEY ("user_id") REFERENCES "user" ("id")
							MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL;
						COMMIT;
					'''

			.catch (e) ->
				query 'ROLLBACK;'
				Promise.reject e

	down: (queryInterface, Sequelize) ->
		queryInterface.dropTable 'session'
