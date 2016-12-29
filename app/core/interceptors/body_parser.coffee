contentType = require 'content-type'
iconv = require 'iconv-lite'

ERROR_CODE = require 'app/modules/error_codes'

CoreError = require 'app/core/CoreError'


getCharset = (req) ->
	try
		return contentType.parse(req).parameters.charset.toLowerCase()
	catch e
		return undefined


module.exports = (promise, req, res) ->
	promise.then ->
		body = req.body
		charset = getCharset(req) or 'utf-8'

		if (charset.substr(0, 4) isnt 'utf-')
			return Promise.reject new CoreError ERROR_CODE.INVALID_REQUEST, "Unsupported charset `#{charset.toUpperCase()}`"

		if req.method isnt 'GET'
			try
				if Buffer.isBuffer(body)
					body = iconv.decode body, charset

				if _.isString(body)
					if not body.length
						body = '{}'

					body = JSON.parse body
					req.body = body

			catch e
				return Promise.reject new CoreError ERROR_CODE.INVALID_REQUEST, 'Invalid json'

		if req.body in [null, undefined]
			req.body = {}

		return req.body
