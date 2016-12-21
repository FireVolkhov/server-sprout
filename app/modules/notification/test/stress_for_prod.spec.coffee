CURRENT_VERSION = require 'app/modules/api/const/current_version'

should = require 'should'
io = require 'socket.io-client'
fs = require 'fs'
tester = require 'app/test/tester'

baseUrl = "https://207.176.81.40/api/v#{CURRENT_VERSION}/"

request = (config) ->
	headers = {}
	data = config.data

	if config.session_id
		headers['X-Session-Id'] = config.session_id

		if not config.type
			config.type = 'application/other-stream'

	data = JSON.stringify data

	headers['Content-Type'] = if config.type then config.type else 'application/json'

	tester.rawRequest
		uri: "#{config.baseUrl or baseUrl}#{config.url}"
		method: config.method or 'POST'
		headers: headers
		body: data

connectWithoutHeaders = (ses_id) ->
	error = new Error()

	localIo = io.connect 'https://207.176.81.40',
		secure: true
		transports: ['websocket']
		'force new connection': true
		path: "/api/v#{CURRENT_VERSION}/socket.io"
		rejectUnauthorized: false

	return new Promise (resolve, reject) ->
		localIo.on 'connect', (data) ->
			localIo.emit 'user/subscribe', session_id: ses_id, (data) ->
				if data?.result is true
					resolve localIo

				else
					error.message = "Data: `#{JSON.stringify data}`"
					reject error

		localIo.on 'disconnect', ->
			error.message = 'Disconnected'
			reject error

toBase64 = (path) ->
	return new Buffer(fs.readFileSync(path)).toString('base64')

xdescribe 'Стресс тест прода и проверка сокета', ->
	admin = {}
	users = _.map [1..9], (i) -> id: "autotest#{i}"
	ioConnect = null

	it 'Создание пользователей', ->
		@timeout 20000

		request
			baseUrl: "https://207.176.81.40:8000/api/v#{CURRENT_VERSION}/"
			url: 'user/login'
			data:
				login: 'admin'
				password: 'admin'
				platform_type: 'web'
				device_id: 'god-admin'

		.then ({body}) ->
			should(body.result).have.property 'session_id'
			admin.session_id = body.result.session_id

		.timeout 1000
		.then ->
			Promise.all _.map [1..9], (i) ->
				request
					baseUrl: "https://207.176.81.40:8000/api/v#{CURRENT_VERSION}/"
					url: 'admin/user/create'
					session_id: admin.session_id
					data:
						login: "autotest#{i}"
						password: "autotest#{i}"
						name: "autotest#{i}"

		.timeout 1000


	it 'Авторизация', ->
		@timeout 20000

		Promise
			.all _.map [1..9], (i) ->
				request
					url: 'user/login'
					data:
						login: "autotest#{i}"
						password: "autotest#{i}"
						platform_type: 'web'
						device_id: "god-user-#{i}"

				.then ({body}) ->
					should(body.result).have.property 'session_id'
					users[i - 1].session_id = body.result.session_id

			.then -> connectWithoutHeaders users[0].session_id
			.then (connect) -> ioConnect = connect

	it 'Отправка файлов', ->
		@timeout 200000

		chat = null
		pings = []

		ioConnect.on 'ping', (data) ->
			if data?.result?.interval
				lastTime = pings[pings.length - 1]?.time

				pings.push
					data: data
					time: _.now()
					interval: if lastTime then _.now() - lastTime else null

		request
			url: 'chat/create'
			session_id: admin.session_id
			data:
				title: 'Stress test'
				member_ids: _.map users, (x) -> x.id

		.then ({body}) ->
			should(body.result.chat).have.property 'id'
			chat = body.result.chat

		.then ->
			file = toBase64 "#{__dirname}/../../files/test/files/1_25mb.docx"

			Promise
				.all _.map users, (user) ->
					Promise.all _.map [0...9], (i) ->
						request
							url: 'message/send'
							session_id: user.session_id
							data:
								chat_id: chat.id
								client_id: '00000000-0000-0000-0000-000000000000'
								text: null
								file:
									content: file
									name: '1_25mb.docx'

		.then ->
			intervals = _.filter pings, (x) -> x.interval
			intervals = _.map intervals, (x) -> x.interval
			interval = intervals.reduce((a, b) -> a + b) / intervals.length

			_.map intervals, (x) -> should(x).not.be.above 3000
			should(interval).not.be.above 2000

		.finally ->
			if chat
				request
					url: 'chat/finish'
					session_id: admin.session_id
					data: chat_id: chat.id
