tester = require 'app/modules/tester'

module.exports =
	run: (task) ->
		request =
			url: 'worker/run'
			data:
				task: task

		tester
			.request request
			.then (res) ->
				result = res

				if result.body
					result = result.body

				if result.result
					result = result.result

				return result
