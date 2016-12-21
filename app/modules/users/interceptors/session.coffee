validateRequest = require 'app/core/validate_request'
Session = require '../models/session'

module.exports = (promise, req, res) ->
	promise.then ->
		xSession = req.headers['x-session-id'] or req.query.sessionId

		if not validateRequest.isUUID(xSession)
			return Promise.reject new CoreError ERROR_CODE.NOT_FOUND_USER

		return Session
			.check xSession, req.$ip
			.then ([user, session]) ->
				req.$user = user
				req.$session = session

			.catch (error) ->
				if error.stack
					console.error error.stack
				return Promise.reject new CoreError error, null, if req.method is 'GET' then 403 else 200