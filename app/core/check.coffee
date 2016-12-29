_check = (target, rule, i, error) ->
	if rule in ['S', 'String']
		if not _.isString(target)
			error.message = "Argument (#{i}) must be `String`"
			console.error error.stack
			return

		else if target.length < 1
			error.message = "Argument (#{i}) must not be an empty `String`"
			console.error error.stack
			return

	if rule in ['O', 'Object']
		if not _.isObject(target)
			error.message = "Argument (#{i}) must be `Object`"
			console.error error.stack
			return

	if rule in ['A', 'Array']
		if not _.isArray(target)
			error.message = "Argument (#{i}) must be `Array`"
			console.error error.stack
			return


check = (args, rules) ->
	error = new TypeError()

	if not _.isArray(args) and not args.length
		console.error new TypeError('Argument `arguments`(1) must be `Array`').stack

	if not _.isString(rules) or not rules
		console.error new TypeError('Argument `rules`(2) must be `String`').stack

	rules = rules.split /\s*,\s*/ig

	if args.length isnt rules.length
		console.error new TypeError('The number of rules is not the same number of arguments. Use `any`').stack

	_.each args, (value, i) ->
		_check value, rules[i], i, error
		return

module.exports = check
