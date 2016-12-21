global.CoreError = class CoreError extends Error
	constructor: (code, message, httpCode) ->
		@code = code
		@message = message
		@httpCode = httpCode
