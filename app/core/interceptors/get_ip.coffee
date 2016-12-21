module.exports = (promise, req, res) ->
	promise.then ->
		req.$ip = (req.headers['x-forwarded-for'] or
			req.connection.remoteAddress or
			req.socket.remoteAddress or
			req.connection.socket.remoteAddress)?.trim()
