module.exports =
	set: (name, value) ->
		if this[name]
			throw new Error "Overwrite config `#{name}`"

		this[name] = value
		return this
