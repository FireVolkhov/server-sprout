pathModule = require('path')
assert = require('assert').ok
rootPath = require('app-root-path')

module.constructor.prototype.require = (path) ->
	assert path, 'missing path'
	assert typeof path is 'string', 'path must be a string'

	if (paths = path.split('/')).length > 1 and paths[0] is 'app'
		path = "#{rootPath}/#{path}"

	this.constructor._load path, this
