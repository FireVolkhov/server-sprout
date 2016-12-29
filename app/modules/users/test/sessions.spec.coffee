should = require 'should'
tester = require "#{require('app-root-path')}/app/modules/tester"

SESSION_TIMEOUT = require '../const/session_timeout'

sequelize = require 'app/sequelize'
worker = require 'app/worker/test/actions'

describe 'Sessions', ->
	user1 = null
	user2 = null
	user3 = null
	user4 = null
	user5 = null
	user6 = null
	user7 = null

	before ->
		@timeout 40000

		tester
			.initPromise
			.then ->
				user1 = tester.users[0]
				user2 = tester.users[1]
				user3 = tester.users[2]
				user4 = tester.users[3]
				user5 = tester.users[4]
				user6 = tester.users[5]
				user7 = tester.users[6]


	it 'Connect without subscribe leads to disconnect after 5 sec', ->
		@timeout 10000

		return new Promise (resolve, reject) ->
			disconnectIsReject = true
			start = _.now()

			tester.connectToSocket()
				.on 'disconnect', ->
					if disconnectIsReject
						reject new Error "Disconnect before 5 sec (#{_.now() - start})"
					else
						resolve()

			setTimeout ->
				disconnectIsReject = false
			, 5000

			setTimeout ->
				reject new Error 'Not disconnected'
			, 6000

	it 'Connect', ->
		@timeout 10000
		user1.connect()


	it 'Remove Session and Socket after 30 min without request', ->
		@timeout 10000
		{Request} = sequelize.models

		user7
			.login()
			.then (result) -> should(result).have.property 'session_id'
			.then -> user7.connect()
			.then ->
				Request.findOne
					where: session_id: user7.activeSession.id
					order: [['date', 'DESC']]

			.then (request) ->
				request.date = new Date(request.date.getTime() - (SESSION_TIMEOUT * 2))
				request.save()

			.then -> worker.run 'deleteOldSessions'
			.then -> user7.setPush({})
			.then (result) ->
				should(result).have.property 'error_code', 2
				should(result.error_message).ok
				should(result).have.property 'result', null

			.finally ->
				user7
					.login()
					.then -> user7.connect()
