module.exports = (promise, req, res) ->
	promise.then ->
		req.body = req.params
