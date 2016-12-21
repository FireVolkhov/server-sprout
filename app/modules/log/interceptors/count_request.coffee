ERROR_CODE = require 'app/core/const/error_codes'

CoreController = require 'app/core/core_controller'
coreController = new CoreController()

module.exports =
	name: 'countRequestInterceptor'
	action: (req, res, next) ->
		user = req.$CurrentUser

		user
			.isHaveManyRequest req.headers['god-mode-on']
			.then (bool) ->
				if bool
					return Promise.reject ERROR_CODE.MANY_REQUESTS

			.then -> next()
			.catch (error) -> coreController.sendError res, error, null, if req.method is 'GET' then 403 else 200
