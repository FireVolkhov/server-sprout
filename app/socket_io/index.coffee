params = require('app/core/console_params').get()
colors = require 'colors/safe'
socketIo = require 'socket.io'
redis = require 'socket.io-redis'
emitter = require 'socket.io-emitter'

module.exports = class SocketIO
	constructor: (config) ->
		@_socketListeners = {}

		@httpServer = config.httpServer
		@path = config.path

		@httpServer.on 'listening', => @start()


	start: ->
		@io = socketIo @httpServer,
			path: @path
			transports: ['websocket', 'polling']

		@io.adapter redis
			host: params.redisHost
			port: params.redisPort

		@emitter = emitter
			host: params.redisHost
			port: params.redisPort

		@io.use (socket, next) =>
			console.log colors.green('Socket request '), @path

			_.each @_socketListeners, (listener, event) ->
				if event is 'connection'
					listener {}, null, socket

				else
					socket.on event, (data, callback) ->
						listener data, callback, socket
				return
			next()


	emit: (args...) ->
		console.log 'Socket event', args
		@io.emit.apply @io, args


	on: (event, handler) ->
		if @_socketListeners[event]
			error = new Error 'Overwrite listener'
			console.error error.stack

		@_socketListeners[event] = handler
