should = require 'should'
tester = require "#{require('app-root-path')}/app/modules/tester"

describe 'Users', ->
	user1 = null

	before ->
		@timeout 20000

		return tester.initPromise
		.then ->
			user1 = tester.users[0]

	describe 'Login', ->
		it 'Invalid requests', ->
			@timeout 20000

			Promise
				.all _.map [
					[null, 200, 101]
					['{login: "45 rgsdfgsfdg 45t", password: "pass1", platform_type: "web"', 200, 101]
					[{}, 200, 101]
					[{login: 'test1'}, 200, 101]
					[{password: 'pass1'}, 200, 101]
					[{platform_type: 'web'}, 200, 101]
					[{login: 'test1', password: 'pass1'}, 200, 101]
					[{login: 'test1', password: 'pass1', platform_type: 'dfbfgsf'}, 200, 101]
					[{login: '45 rgsdfgsfdg 45t', password: 'pass1', platform_type: 'web', device_id: 'test id'}, 200, 3]
				], ([data, status, error_code]) ->
					tester
						.request
							url: "user/login"
							data: data

					.then (res) ->
						should(res).have.property 'status', status
						should(res.body).have.property 'error_code', error_code
						should(res.body.error_message).ok
						should(res.body).have.property 'result', null

		it 'Valid login', ->
			@timeout 20000

			user1
				.login()
				.then (result) ->
					should(result).have.property 'session_id'


	describe 'Logout', ->
		it 'Session not work after logout', ->
			@timeout 20000

			user1
				.login()
				.then -> user1.logout()
				.then -> user1.setPush({})
				.then (res) ->
					res.body = JSON.parse res.body.toString 'utf-8'

					should(res).have.property 'status', 200
					should(res.body).have.property 'error_code', 2
					should(res.body.error_message).ok
					should(res.body).have.property 'result', null


#			.then ([user]) -> Promise.all [user, usersActions.logout(user)]
#			.then ([user]) ->
#				tester
#				.request
#						url: "/v#{tester.CURRENT_VERSION}/user/push/set"
#						data:
#							push_token: '4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab'
#						session_id: user.sessionId
#						withoutDecryption: true
#						serverKey: user.serverKey
#						clientKey: user.clientKey
#
#			.then (res) ->
#				res.body = JSON.parse res.body.toString 'utf-8'
#
#				should(res).have.property 'status', 200
#				should(res.body).have.property 'error_code', 2
#				should(res.body.error_message).ok
#				should(res.body).have.property 'result', null


	describe 'Set push token', ->
		it 'Valid request', ->
			@timeout 10000

			android = tester.users[0]
			ios = tester.users[2]
			web = tester.users[4]

			Promise
				.all [
					android.setPush push_token: '4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab'
					ios.setPush push_token: '4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dac'
					web.setPush push_token: '4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dab4cd33dad'
				]
