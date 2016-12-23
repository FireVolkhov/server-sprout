ERROR_CODE = require 'app/modules/error_codes'

module.exports = class CoreError extends Error
	constructor: (codeOrError, message = '', httpCode = 200) ->
		if codeOrError instanceof CoreError
			coreError = codeOrError

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

		if codeOrError instanceof Error
			error = codeOrError

			@code = ERROR_CODE.INTERNAL_SERVER
			@stack = error.stack
			@message = message or error.message
			@httpCode = httpCode
			return this

		code = codeOrError.CODE
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
