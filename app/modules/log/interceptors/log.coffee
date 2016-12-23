Request = require '../models/request'

module.exports = (promise, req, res) ->
	promise.then ->
		user = req.$user
		session = req.$session

		return Request
			.create
				user_id: user.id
				session_id: session.id
