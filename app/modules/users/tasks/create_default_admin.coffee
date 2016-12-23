worker = require 'app/worker'

worker.registerTask
	name: 'createDefaultAdmin'
	action: ->
		User
			.find where: login: 'admin'
			.then (admin) ->
				if admin
					return admin

				else
					return User
						.create
							name: 'Admin'
							login: 'admin'
							password: 'admin'

			.then (admin) -> admin.passwordSet 'admin'
			.then (admin) ->
				admin.is_admin = true
				admin.save()

			.then -> true
