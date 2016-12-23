params = []
consoleNames = []
envNames = []
result = null

setParam = (name, envName, consoleNames, defaultValue) ->
	params.push
		name: name
		envName: envName
		consoleNames: consoleNames
		defaultValue: defaultValue

	return this

parseParams = (env, argv) ->
	parsedParams = {}
	envKeys = _.keys env

	_.each params, (p) ->
		parsedParams[p.name] = p.defaultValue
		parsedParams[p.name] ?= null

		if p.envName in envKeys
			parsedParams[p.name] = process.env[p.envName]
		return

	argv.forEach (val, index, array) ->
		if array[index + 1]
			if (found = _.find params, (p) -> val in p.consoleNames)
				parsedParams[found.name] = array[index + 1];
		return

#	_.each parsedParams, (value, key) ->
#		if (found = _.find params, (x) -> x.name is key)
#			env[found.envName] = value
		return

	result = parsedParams
	return result

get = -> result

module.exports =
	get: get
	setParam: setParam
	parseParams: parseParams
