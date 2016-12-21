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
	if (task = _.find tasks, (x) -> x.name is name)
		start = _.now()

		if task.isRun
			if log then logger colors.yellow '-X Задача еще активна'

		else
			task.isRun = true

			Promise
				.resolve task.action()
				.then ->
					task.isRun = false

					if log then logger colors.green "+++ Задача `#{task.name}` выполнена за #{_.now() - start} мс"

				.catch (e) ->
					console.error colors.red("--- Задача `#{task.name}` выполнена с ошибкой"), e.stack
					task.isRun = false

	return this

start = ->
	_.each tasks, (task) ->
		if task.interval
			task._interval = setInterval ->
				run task.name
			, task.interval

		return this

module.exports =
	run: run
	start: start
	registerTask: registerTask
