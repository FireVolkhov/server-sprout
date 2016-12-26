SESSION_TIMEOUT = require '../const/session_timeout'

worker = require 'app/worker'
sequelize = require 'app/sequelize'

module.exports = worker.registerTask
	name: 'deleteOldSessions'
	interval: 60 * 1000
	action: ->
		{Session, Request} = sequelize.models
		# TODO: Прокачать запрос в БД

		Session
			.findAll
				include: [
					model: Request
					as: 'Requests'
					order: [['date', 'DESC']]
					limit: 1
					offset: 0
					separate: true
				]

			.then (sessions) ->
				Promise.all _.map sessions, (x) ->
					request = x.Requests[0]
					requestTime = request.date.getTime()
					sessionTime = _.now() - SESSION_TIMEOUT

					if requestTime <= sessionTime
						return x.destroy()

			.then -> true
