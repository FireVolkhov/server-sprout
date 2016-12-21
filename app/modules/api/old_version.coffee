ERROR_CODE = require 'app/modules/error_codes'
CURRENT_VERSION = require './const/current_version'

module.exports = (req, res, next) ->
	res.json
		result: null
		error_message: "#{ERROR_CODE.OLD_VERSION.MESSAGE} Current version `v#{CURRENT_VERSION}`."
		error_code: ERROR_CODE.OLD_VERSION.CODE
