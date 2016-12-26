module.exports =
	up: (queryInterface, Sequelize) ->
		query = queryInterface.sequelize.query.bind queryInterface.sequelize

		queryInterface
			.createTable 'request',
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

			.then -> queryInterface.addIndex 'request', ['id'], unique: true
			.then ->
				query '''
          BEGIN;
            ALTER TABLE "request"
            ADD CONSTRAINT "request_user_id_fkey"
            FOREIGN KEY ("user_id") REFERENCES "user" ("id")
            MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL;

            ALTER TABLE "request"
            ADD CONSTRAINT "request_session_id_fkey"
            FOREIGN KEY ("session_id") REFERENCES "session" ("id")
            MATCH SIMPLE ON UPDATE CASCADE ON DELETE SET NULL;
          COMMIT;
        '''

			.catch (e) ->
				query 'ROLLBACK;'
				Promise.reject e

	down: (queryInterface, Sequelize) ->
		queryInterface.dropTable 'request'
