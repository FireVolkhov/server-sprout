ERROR_CODE = require 'app/modules/error_codes'

module.exports = class CoreError extends Error
	constructor: (error, message = '', httpCode = 200) ->
		if error instanceof CoreError
			coreError = error

			if message
				errorKey = _.find _.keys(ERROR_CODE), (key) -> ERROR_CODE[key].CODE is coreError.code
				MESSAGE = ERROR_CODE[errorKey].MESSAGE

				if _.isFunction(MESSAGE)
					message = MESSAGE message
				else if not message
					message = MESSAGE

				coreError.message = message

			if httpCode isnt 200
				coreError.httpCode = httpCode

			return coreError

		if error instanceof Error
			@code = ERROR_CODE.INTERNAL_SERVER.CODE
			@stack = error.stack
			@message = ERROR_CODE.INTERNAL_SERVER.MESSAGE
			@httpCode = httpCode
			return this

		code = error.CODE
		errorKey = _.find _.keys(ERROR_CODE), (key) -> ERROR_CODE[key].CODE is code
		MESSAGE = ERROR_CODE[errorKey].MESSAGE

		if _.isFunction(MESSAGE)
			message = MESSAGE message
		else if not message
			message = MESSAGE

		@code = code
		@message = message
		@httpCode = httpCode
		return this
