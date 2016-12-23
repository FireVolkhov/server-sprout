rootPath = require('app-root-path').path
coreTester = require "#{rootPath}/app/tester"

require 'app/modules/users'
require 'app/modules/log'

CURRENT_VERSION = require 'app/modules/api/const/current_version'


request = (config) ->
	config.url = "#{@baseUrl}:#{@port}/v#{CURRENT_VERSION}/#{config.url}"
	coreTester.request config

connectToSocket = ->
	coreTester.connectToSocket "#{@baseUrl}:#{@port}", path: "/v#{CURRENT_VERSION}/socket.io"

mustHavePushNotification = (token, timeout) ->
	coreTester.mustHavePushNotification token, timeout

mustNotHavePushNotification = (token, timeout) ->
	coreTester.mustNotHavePushNotification token, timeout

service =
	CURRENT_VERSION: CURRENT_VERSION

	initPromise: null
	users: null

	port: 3010
	baseUrl: 'http://localhost'

	request: request
	connectToSocket: connectToSocket
	mustHavePushNotification: mustHavePushNotification
	mustNotHavePushNotification: mustNotHavePushNotification

service.initPromise = coreTester
	.runServer service.port
	.then -> require "app/modules/users/test/init"
	.then (users) -> service.users = users
	.timeout 3000

module.exports = service
