promise = Promise
	.timeout()
	.then -> Promise.all _.map [1..10], (x) ->
		{User} = require('app/sequelize').models

		User
			.create
				name: "Пользователь для автотестов #{x}"
				login: "autotest#{x}"
				password_hash: "autotest#{x}"

			.catch -> true
			.then ->
				UserModel = require './user_model'
				user = new UserModel
					login: "autotest#{x}"
					password: "autotest#{x}"

				user.addDevice
					id: "web#{x}"
					platform_type: 'web'

				return user

			.then (user) -> Promise.all [user, user.login()]
			.then ([user]) -> Promise.all [user, user.connect()]
			.then ([user]) -> user

module.exports = promise
