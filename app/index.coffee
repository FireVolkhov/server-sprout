console.log "\n\n\n ###### Start #{new Date()} ######",

global._ = require 'lodash'
require './core/require'
require 'app/core/Promise'

require 'app/modules/config'
params = require('app/core/console_params').get()

require 'app/sequelize'
worker = require 'app/worker'
require 'app/modules'

if params.run
	worker
		.run params.run, true
		.then -> process.exit 0

else
	require 'app/push_notification'
	require 'app/socket_io'
	httpServer = require 'app/http_server'
	httpServer.on 'listening', -> worker.start()
