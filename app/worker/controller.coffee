CoreController = require 'app/core/CoreController'

bodyParser = require 'app/core/interceptors/body_parser'
trimmer = require 'app/core/trimmer'
validateRequest = require 'app/core/validate_request'
jsonResponseParser = require 'app/core/response_parsers/json'
worker = require 'app/worker'

module.exports = new CoreController
	logger: 'workers/run'

	methods:
		run:
			interceptors: [
				bodyParser
				trimmer ['task']
				validateRequest.get 'task', ['required', 'string']
			]
			responseParsers: [jsonResponseParser]
			action: (data) ->
				worker
					.run data.task
					.then -> true
