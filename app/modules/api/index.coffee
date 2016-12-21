{Router} = require 'express'

CURRENT_VERSION = require './const/current_version'

express = require 'app/express'

router = new Router()
router.use require './user'

require './io'
oldVersionRout = require './old_version'

apiModule = {}

_.map [1...CURRENT_VERSION], (oldVersion) ->
	express.use "/v#{oldVersion}", oldVersionRout

apiModule[CURRENT_VERSION] = router

_.each apiModule, (rout, version) ->
	express.use "/v#{version}", rout
	return

module.exports = apiModule
