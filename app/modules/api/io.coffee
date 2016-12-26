CURRENT_VERSION = require './const/current_version'

httpServer = require 'app/http_server'
socketIo = require 'app/socket_io'

module.exports = new socketIo
	httpServer: httpServer
	path: "/v#{CURRENT_VERSION}/socket.io"
