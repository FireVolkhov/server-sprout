CoreError = require 'app/core/CoreError'

module.exports = (promise, scoket, callback) ->
	promise
		.then (data) ->
			response =
				result: data
				error_code: 0
				error_message: null

			callback?(response)

			return response

		.catch (error) -> Promise.reject new CoreError error
		.catch (error) ->
			response =
				result: null
				error_message: error.message or null
				error_code: error.code

			callback?(response)

			return Promise.reject error
