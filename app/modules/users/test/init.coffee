exec = require('child_process').exec

users = []
start = _.now()

_exec = (command) ->
	new Promise (resolve, reject) ->
		exec command, (error, stdout, stderr) ->
			if error
				reject error
			else if stderr
				reject new Error stderr
			else
				resolve stdout

promise = Promise
	.timeout()
	.then -> Promise.all _.map [1..1000], (x) ->
		{User} = require('app/sequelize').models

		User
			.create
				name: "Пользователь для автотестов #{x}"
				login: "autotest#{x}"
				password_hash: "autotest#{x}"

			.catch (e) -> true
			.then ->
				UserModel = require './user_model'
				user = new UserModel
					login: "autotest#{x}"
					password: "autotest#{x}"

				user.addDevice
					id: "web#{x}"
					platform_type: 'web'

				return user

			.then (user) -> users.push user
#			.then (user) -> Promise.all [user, user.login()]
#			.then ([user]) -> Promise.all [user, user.connect()]
#			.then ([user]) -> user
	.timeout 5000
	.then -> console.log "Start"
	.then -> Promise.all _.map users, (u) -> u.login()
	.then -> console.log "Stop #{_.now() - start} ms"
	.then ->
		tester = require "app/tester"
		_exec "cat /proc/#{tester.server.pid}/stat"

	.then (result) ->
		result = result.trim().split(" ")
		result.unshift("")

		console.log "utime:", result[14]
		console.log "stime:", result[15]
		console.log "total_time:", (+result[14]) + (+result[15])

		console.log "cutime:", result[16]
		console.log "cstime:", result[17]
		console.log "total_time :", (+result[14]) + (+result[15]) + (+result[16]) + (+result[17])

	.then -> Promise.reject()

module.exports = promise
