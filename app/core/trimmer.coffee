module.exports = (fieldNames) ->
	return (promise, req, res) ->
		promise.then ->
			_.each fieldNames, (fieldName) ->
				field = _.get req.body, fieldName

				if _.isString(field) and field.length
					_.set req.body, fieldName, field.trim()

				return
