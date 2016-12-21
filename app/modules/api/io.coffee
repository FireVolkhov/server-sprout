CURRENT_VERSION = require './const/current_version'

socketIo = require 'app/socket_io'
socketIo
	.registerRout
		name: 'lastVersion'
		path: "/v#{CURRENT_VERSION}/socket.io"
		interceptors: [
			'sessionInterceptor'
			'countRequestInterceptor'
			'messageReadInterceptor'
		]
