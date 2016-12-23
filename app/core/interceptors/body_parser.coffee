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

		if not body?.length and not _.keys(body).length and not Buffer.isBuffer(body)
			body = '{}'

		if body?.length or Buffer.isBuffer(body)
			body = iconv.decode body, charset

		try
			if req.method isnt 'GET'
				req.body = JSON.parse body
		catch e
			return Promise.reject new CoreError ERROR_CODE.INVALID_REQUEST, 'Invalid json'
