_check = (target, rule, i, error) ->
	if rule in ['S', 'String']
		if not _.isString(target)
			error.message = "Argument (#{i}) must be `String`"
			throw error

		else if target.length < 1
			error.message = "Argument (#{i}) must not be an empty `String`"
			throw error

	if rule in ['O', 'Object']
		if not _.isObject(target)
			error.message = "Argument (#{i}) must be `Object`"
			throw error

	if rule in ['A', 'Array']
		if not _.isArray(target)
			error.message = "Argument (#{i}) must be `Array`"
			throw error


check = (args, rules) ->
	error = new Error

	if not _.isArray(args) and not args.length
		throw new Error 'Argument `arguments`(1) must be `Array`'

	if not _.isString(rules) or not rules
		throw new Error 'Argument `rules`(2) must be `String`'

	rules = rules.split /\s*,\s*/ig

	if args.length isnt rules.length
		throw new Error 'The number of rules is not the same number of arguments. Use `any`'

	_.each args, (value, i) ->
		_check value, rules[i], i, error
		return

module.exports = check
