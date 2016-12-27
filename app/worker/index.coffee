colors = require 'colors/safe'

logger = (text) -> console.log text
tasks = {}

#	name: 'demo',
#	interval: 30 * 1000,
#	action: -> new Promise
registerTask = (task) ->
	tasks[task.name] = task
	return this


run = (name, log = true) ->
	return Promise.resolve()
		.then ->
			if (task = _.find tasks, (x) -> x.name is name)
				start = _.now()

				if task.isRun
					if log then logger colors.yellow '-X Задача еще активна'

				else
					task.isRun = true

					return Promise
						.resolve task.action()
						.finally -> task.isRun = false
						.then ->
							if log then logger colors.green "+++ Задача `#{task.name}` выполнена за #{_.now() - start} мс"

						.catch (e) ->
							console.error colors.red("--- Задача `#{task.name}` выполнена с ошибкой"), e.stack
							return Promise.reject e

			else
				error = new Error "Task `#{name}` not found"
				console.error error.stack
				return Promise.reject error


start = ->
	_.each tasks, (task) ->
		if task.interval
			task._interval = setInterval ->
				run task.name
			, task.interval

		return this


openApi = ->
	CURRENT_VERSION = require 'app/modules/api/const/current_version'

	controller = require './controller'
	express = require 'app/express'
	express.use "/v#{CURRENT_VERSION}/worker/run", controller.getRout 'run'


module.exports =
	run: run
	start: start
	registerTask: registerTask
	openApi: openApi
