process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0

request = require 'request'
spawn = require('child_process').spawn
require 'buffer-concat'
fs = require 'fs'
io = require 'socket.io-client'

global._ = require 'lodash'
require './../core/require'
require 'app/core/Promise'

require 'app/modules/config'
require 'app/sequelize'


rawRequest = (config, stack) ->
	chunks = []
	size = 0

	new Promise (resolve, reject) ->
		res = request config, (error, response, body) ->
			if response
				response.status = response.statusCode

			if error
				reject error
				return

			data = Buffer.concat chunks, size

			console.log data.toString 'utf-8'

			if response.request.method is 'GET'
				response.body = data

			else
				try
					response.body = JSON.parse data.toString 'utf-8'

				catch e
					e.stack += '\n' + stack.replace 'Error\n', ''
					throw e

			resolve response

		res.on 'data', (chunk) ->
			size += chunk.length
			chunks.push chunk

		res.on 'socket', (socket) ->
			socket.setTimeout 200000


serviceRequest = (config) ->
	stack = new Error().stack

	headers = {}
	data = config.data
	console.log data
	data = JSON.stringify data

	if config.session_id
		headers['X-Session-Id'] = config.session_id

		if not config.type
			config.type = 'application/other-stream'

	headers['Content-Type'] = if config.type then config.type else 'application/json'

	@rawRequest
		uri: config.url
		method: config.method or 'POST'
		headers: headers
		body: data
	, stack


connectToSocket = (url, config) ->
	config = _.extend _.clone(@defaultSocketConfig), config
	return io.connect url, config


runServer = (port) ->
	dir = './log'

	if not fs.existsSync(dir)
		fs.mkdirSync dir

	wstream = fs.createWriteStream './log/test_server_out.log'

	wstream.write '### START ###\n\n'

	@server = spawn 'node', ['./app/index.js', '--port', port, '--testing']

	@server.stdout.on 'data', (data) ->
		text = data.toString().replace /\[\d{1,2}m/ig, ''
		wstream.write text

		pushEventReg = /Push event to `[^`]*` tokens: `([^`]+)`/i
		matches = text.match pushEventReg

		if matches?.length
			tokens = JSON.parse matches[1]

			_.map @pushHandlers, (x) -> x?(tokens)

	@server.stderr.on 'data', (data) ->
		wstream.write '\n!!! ERROR >>>\n\n'
		wstream.write "#{data.toString().replace /\[\d{1,2}m/ig, ''}"
		wstream.write '<<< ERROR END\n\n'

	@server.on 'close', (code) ->
		wstream.write "server process exited with code #{code}"
		wstream.write '\n### END ###\n'
		wstream.end()

	return Promise.timeout 5000


mustHavePushNotification = (token, timeout = 2000) ->
	error = new Error "User `#{token}` must have push notification"
	listener = null

	promise = new Promise (resolve, reject) =>
		listener = (tokens) ->
			tokens = [].concat tokens.android, tokens.ios, tokens.web

			if _.find(tokens, (x) -> x is token)
				resolve()

		@pushHandlers.push listener

		setTimeout ->
			reject error
		, timeout

	promise.finally =>
		_.remove @pushHandlers, (x) -> x is listener


mustNotHavePushNotification = (token, timeout = 2000) ->
	error = new Error "User `#{token}` must not have push notification"
	listener = null

	promise = new Promise (resolve, reject) =>
		listener = (tokens) ->
			tokens = [].concat tokens.android, tokens.ios, tokens.web

			if _.find(tokens, (x) -> x is token)
				reject error

		@pushHandlers.push listener

		setTimeout ->
			resolve()
		, timeout

	promise.finally =>
		_.remove @pushHandlers, (x) -> x is listener


module.exports =
	server: null
	pushHandlers: []
	defaultSocketConfig:
		secure: true
		transports: ['websocket']
		'force new connection': true
		path: "/socket.io"
		rejectUnauthorized: false

	rawRequest: rawRequest
	request: serviceRequest
	connectToSocket: connectToSocket
	runServer: runServer
	mustHavePushNotification: mustHavePushNotification
	mustNotHavePushNotification: mustNotHavePushNotification
