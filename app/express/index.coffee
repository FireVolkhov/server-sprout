params = require('app/core/console_params').get()
config = require('app/core/config').express
express = require('express')()
requestLogger = require 'morgan'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'

express.use requestLogger 'dev'
express.use bodyParser.raw
	limit: config.requestLimit
	type: '*/*'
express.use bodyParser.json
	limit: config.requestLimit
express.use bodyParser.urlencoded
	limit: config.requestLimit
	extended: true
express.use cookieParser()
express.set 'port', params.port

module.exports = express
