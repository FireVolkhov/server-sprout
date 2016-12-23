check = require 'app/core/check'
Sequelize = require 'sequelize'
config = require('app/core/config').sequelize
sequelize = new Sequelize config.connectString, config.connectOptions

models = {}
modelConfigs = {}

getArgs = (func) ->
	(func + '')
		.replace /[/][/].*$/mg,''
		.replace /\s+/g, ''
		.replace /[/][*][^/*]*[*][/]/g, ''
		.split('){', 1)[0]
		.replace /^[^(]*[(]/, ''
		.replace /\=[^,]+/g, ''
		.split ','
		.filter Boolean


capitalizeFirstLetter = (string) ->
	check arguments, 'S'
	return string.charAt(0).toUpperCase() + string.slice(1)


getModelsByNames = (names) ->
	check arguments, 'A'

	return _.map names, (name) ->
		if not models[name]
			throw new Error "Model `#{name}` not found."

		return models[name]


addModel = (name, fields, options) ->
	error = new Error
	check arguments, 'S, O, O'

	if config.defaultModel.capitalizeFirstLetter
		name = capitalizeFirstLetter name

	if modelConfigs[name]
		throw new Error "Overwrite model `#{name}`"

	options = _.extend _.clone(config.defaultModel.options), options
	links = options.links
	delete options.links

	modelConfigs[name] =
		name: name
		fields: fields
		options: options
		links: links
		_error: error

	return models[name] = sequelize.define name, fields, options


setTimeout ->
	_.each modelConfigs, (config) ->
		if config.links
			if not _.isFunction(config.links)
				throw new Error '`options.links` must be `Function`'

			foundModels = getModelsByNames getArgs config.links

			try
				config.links.apply null, foundModels
			catch error
				error.message += " From config for model `config.name`"
				error.stack = config._error.stack
				throw error

		return


module.exports =
	models: models
	rawSequelize: sequelize
	addModel: addModel
