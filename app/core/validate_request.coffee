ERROR_CODE = require 'app/modules/error_codes'
CoreError = require 'app/core/CoreError'

emailReg = /^[-a-z0-9~!$%^&*_=+}{\'?]+(\.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i

_required = (value) ->
	if _.isString(value) or _.isArray(value)
		return value.length > 0

	if _.isNumber(value)
		return not _.isNaN(value)

	if _.isObject(value)
		return _.keys(value).length > 0

	if _.isBoolean(value)
		return true

	return !!value


isUUID = (value) ->
	regExp = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i
	regExp.test value

_validators =
	required: (name) ->
		return (promise, req, res) =>
			promise.then ->
				console.log '>>> req.body', req.body
				if not _required(req.body?[name])
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Fill the field `#{name}`",
						if req.method is 'GET' then 400 else 200
					)

	bool: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not _.isBoolean(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `bool`",
						if req.method is 'GET' then 400 else 200
					)

	int: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not _.isInteger(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `int`",
						if req.method is 'GET' then 400 else 200
					)

	notNegative: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and _.isInteger(field) and field < 0
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Number `#{name}` should be positive",
						if req.method is 'GET' then 400 else 200
					)

	enum: (name, allowValues) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field)
					if not (field in allowValues)
						allowValuesText = _.map allowValues, (x) -> "`#{x}`"

						return Promise.reject new CoreError(
							ERROR_CODE.INVALID_REQUEST,
							"Fill the field `#{name}` from [#{allowValuesText.join(', ')}]",
							if req.method is 'GET' then 400 else 200
						)

	string: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not _.isString(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `string`",
						if req.method is 'GET' then 400 else 200
					)

	object: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not _.isObject(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `object`",
						if req.method is 'GET' then 400 else 200
					)

	array: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not _.isArray(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `array`",
						if req.method is 'GET' then 400 else 200
					)

	email: (name) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and not emailReg.test(field)
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be in the format `#{emailReg.toString()}`",
						if req.method is 'GET' then 400 else 200
					)

	maxLength: (name, maxLength) ->
		return (promise, req, res) =>
			promise.then ->
				field = _.get req.body, name

				if _required(field) and _.isNumber(field.length) and field.length > maxLength
					return Promise.reject new CoreError(
						ERROR_CODE.INVALID_REQUEST,
						"Field `#{name}` should be no more than `#{maxLength}` characters in length",
						if req.method is 'GET' then 400 else 200
					)

	uuid: (name) ->
		return (promise, req, res) =>
			promise.then ->
				fields = _.get req.body, name

				if _required(fields)
					if not _.isArray(fields)
						fields = [fields]

					for field in fields
						if not isUUID field
							return Promise.reject new CoreError(
								ERROR_CODE.INVALID_REQUEST,
								"Field `#{name}` should be in the format `/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i`",
								if req.method is 'GET' then 400 else 200
							)

get = (field, validators) ->
	_.compact _.map validators, (validatorName) =>
		if _.isFunction(_validators[validatorName])
			return _validators[validatorName](field)
		else
			throw new Error "Validator `#{validatorName}` not found"

module.exports =
	get: get
	enum: _validators.enum
	maxLength: _validators.maxLength
	isUUID: isUUID
