Request = require '../models/request'

module.exports =
	name: 'logInterceptor'
	action: (req, res, next) ->
		user = req.$CurrentUser
		session = req.$CurrentSession

		Request
			.create
				user_id: user.id
				session_id: session.id

			.then -> next()
