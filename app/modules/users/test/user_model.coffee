tester = require 'app/modules/tester'

UserModel = class UserModel
	constructor: (model) ->
		@_login = model.login
		@_password = model.password

		@devices = []
		@activeDevice = null

		@sessions = []
		@activeSession = null


	addDevice: (device) ->
		if not @activeDevice
			@devices.push device
			@activeDevice = device


	addSession: (session) ->
		if not @activeSession
			@sessions.push session
			@activeSession = session


	login: ->
		device = @activeDevice

		request =
			url: "user/login"
			data:
				login: @_login
				password: @_password
				device_id: device.id
				platform_type: device.platform_type

		tester
			.request request
			.then (res) =>
				@addSession
					id: res.body.result.session_id
					device: device

				result = res

				if result.body
					result = result.body

				if result.result
					result = result.result

				return result


	logout: ->
		session = @activeSession
		request =
			url: "user/logout"
			session_id: session.id

		tester
			.request request
			.then (res) ->
				result = res

				if result.body
					result = result.body

				if result.result
					result = result.result

				return result


	setPush: (data) ->
		session = @activeSession
		request =
			url: "user/push/set"
			data: data
			session_id: session.id

		tester
			.request(request)
			.then (res) ->
				result = res

				if result.body
					result = result.body

				if result.result
					result = result.result

				return result


	connect: ->
		error = new Error()
		session = @activeSession

		if not session.socketConnetions
			session.socketConnetions = []

		io = tester.connectToSocket()
		session.socketConnetions.push io

		new Promise (resolve, reject) =>
				io.on 'connect', (data) =>
					sendData = session_id: session.id

					io.emit 'user/subscribe', sendData, (data) =>
						if data?.result is true
							resolve io

						else
							error.message = "Data: `#{JSON.stringify data}`"
							reject error

				io.on 'disconnect', ->
					error.message = 'Disconnected'
					reject error

			.catch (e) ->
				_.remove session.socketConnetions, (x) -> x is io
				Promise.reject e


	emit: (event, data, timeout = 2000) ->
		error = new Error()

		io = @activeSession.socketConnetions[0]

		new Promise (resolve, reject) ->
			io.emit event, data, (result) ->
				result = JSON.parse result

				if result?.error_code is 0
					resolve result.result

				else
					error.message = "Data: `#{JSON.stringify result}`"
					reject error

			setTimeout ->
				error.message = 'Not have response'
				reject error
			, timeout


	waitMessage: (event, time = 2000) ->
		error = new Error "User `#{@_login}` must have message #{event}"
		listener = null
		io = @activeSession.socketConnetions[0]

		promise = new Promise (resolve, reject) ->
			listener = (data) ->
				if _.isString(data)
					data = JSON.parse data

				resolve data.result

			io.on event, listener

			setTimeout ->
				reject error
			, time

		promise.finally => io.off event, listener


	notWaitMessage: (event, time = 2000) ->
		error = new Error "User `#{@_login}` must not have message `#{event}`"
		listener = null
		io = @activeSession.socketConnetions[0]

		promise = new Promise (resolve, reject) ->
			listener = (data) ->
				data = JSON.parse data

				error.message += ", data: #{JSON.stringify data}"
				reject error

			io.on event, listener

			setTimeout ->
				resolve()
			, time

		promise.finally => io.off event, listener


	saveAllMessage: (event, time = 2000) ->
		io = @activeSession.socketConnetions[0]
		messages = []

		listener = (data) ->
			data = JSON.parse data
			messages.push data.result

		return new Promise (resolve) ->
			io.on event, listener

			setTimeout ->
				io.off event, listener
				resolve messages
			, time

module.exports = UserModel
