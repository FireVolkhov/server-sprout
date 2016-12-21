colors = require 'colors/safe'

ERROR_CODE = require 'app/core/const/error_codes'

CoreController = require 'app/core/core_controller'
Request = require '../models/request'

coreController = new CoreController()

check = (socket) ->
	user = socket.$CurrentUser

	user
		.isHaveManyRequest socket.handshake.headers['god-mode-on']
		.then (bool) ->
			if bool
				return Promise.reject ERROR_CODE.MANY_REQUESTS


module.exports =
	name: 'countRequestInterceptor'
	priority: 300
	action: (io, socket, next) ->
		if socket.$loginPromise
			socket.$loginPromise
				.then -> check socket
				.catch (error) ->
					if not error in ['Timeout disconnect', 'Bad authorization disconnect']
						console.log colors.red('Disconnect with many requests'), socket.handshake
						socket.disconnect()

						setTimeout ->
							socket.disconnect true

			next()

		else
			return check socket
				.then -> next()
				.catch ->
					console.log colors.red('Disconnect with many requests'), socket.handshake
					socket.disconnect()

					setTimeout ->
						socket.disconnect true

					return Promise.reject()
