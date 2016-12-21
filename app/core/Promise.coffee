if not Promise.prototype.finally
	Promise.prototype.finally = (func) ->
		promise = @then (result) ->
			return Promise
				.resolve func()
				.then -> result

		promise.catch (result) ->
			return Promise
				.resolve func()
				.then -> Promise.reject result

		return promise

if not Promise.timeout
	Promise.timeout = (time = 0) ->
		return new Promise (resolve) -> setTimeout resolve, time

if not Promise.prototype.timeout
	Promise.prototype.timeout = (time) ->
		return @then (result) ->
			return Promise
				.timeout time
				.then -> result
