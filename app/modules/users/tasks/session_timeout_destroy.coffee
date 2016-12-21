#SESSION_TIMEOUT = require '../const/session_timeout'
#PLATFORM_TYPE = require '../const/platform_type'
#
#worker = require 'app/worker'
#socketIo = require 'app/modules/notification'
#
#Session = require '../models/session'
#Request = require 'app/modules/log/models/request'
#Device = require 'app/modules/notification/models/device'
#
#module.exports = worker.registerTask
#	name: 'deleteOldSessions'
#	interval: 60 * 1000
#	action: ->
#		Session
#			.findAll
#				include: [
#					model: Request
#					as: 'Requests'
#					order: [['date', 'DESC']]
#					limit: 1
#					offset: 0
#					separate: true
#				,
#					model: Device
#					as: 'Device'
#					where:
#						platform: PLATFORM_TYPE.WEB
#				]
#
#			.then (sessions) ->
#				Promise.all _.map sessions, (x) ->
#					[request] = x.Requests
#					requestTime = request.date.getTime()
#					sessionTime = _.now() - SESSION_TIMEOUT
#					if requestTime <= sessionTime
#						Promise.all [
#							socketIo.disconnect [x]
#							x.destroy()
#						]
#
#			.then -> true
