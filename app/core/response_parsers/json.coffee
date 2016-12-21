module.exports = (promise, req, res) ->
	promise
		.then (data) ->
			response =
				result: data
				error_code: 0
				error_message: null

			res.status 200
			res.json response

			return response

		.catch (error) -> Promise.reject new CoreError error
		.catch (error) ->
			console.error error.stack

			response =
				result: null
				error_message: error.message or null
				error_code: error.code

			res.status error.httpCode
			res.json response

			return Promise.reject error
