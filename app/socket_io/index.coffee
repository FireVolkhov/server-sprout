params = require('app/core/console_params').get()
colors = require 'colors/safe'
socketIo = require 'socket.io'
redis = require 'socket.io-redis'
emitter = require 'socket.io-emitter'
httpServer = require 'app/http_server'

interceptors = []
routs = {}

registerInterceptor = (interceptor) ->
	interceptors.push interceptor
	interceptors = _.sortBy interceptors, 'priority'

registerRout = (config = {}) ->
	routs[config.name] = config

	return routs[config.name]._initPromise = new Promise (resolve) =>
		routs[config.name]._resolve = resolve

start = ->
	for name, config of routs
		io = socketIo httpServer,
			path: config.path
			transports: ['websocket', 'polling']

		io.adapter redis
			host: params.redisHost
			port: params.redisPort

		io.emitter = emitter
			host: params.redisHost
			port: params.redisPort

		interc = _.map config.interceptors, (name) -> _.find interceptors, (x) -> x.name is name
		interc = _.compact interc

		emit = io.emit
		io.emit = (args...) ->
			console.log 'Socket event', args
			emit.apply this, args

		io.use (socket, next) ->
			console.log colors.red('Socket request '), socket.handshake
			next()

		io.on 'connect', (socket) ->
			if socket.$loginPromise
				console.log colors.green 'Connection with promise'

				socket.$loginPromise
					.then ->
						console.log colors.green('Connection '), socket.$CurrentUser.name

					.catch (e) ->
						if e?.stack
							console.error e.stack

			else
				console.error colors.red('Connection without promise')

		_.map interc, (interceptor) ->
			io.use (socket, next) ->
				interceptor.action io, socket, next

		@[name] = io
		config._resolve io
	return this

httpServer.on 'listening', -> start()

module.exports =
	registerInterceptor: registerInterceptor
	registerRout: registerRout
