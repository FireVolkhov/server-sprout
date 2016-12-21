params = require('app/core/console_params').get()
express = require 'app/express'
httpServer = require('http').createServer express
httpServer.listen params.port

httpServer.on 'error', (error) ->
	if error.syscall isnt 'listen'
		throw error

	bind = "Port #{params.port}"

	switch (error.code)
		when 'EACCES'
			console.error "#{bind} requires elevated privileges"
			process.exit 1
			break

		when 'EADDRINUSE'
			console.error "#{bind} is already in use"
			process.exit 1
			break

		else
			throw error

httpServer.on 'listening', ->
	console.log "Internal api server listen on #{params.port}"

module.exports = httpServer
