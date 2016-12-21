fs = require 'fs'

rootPath = require('app-root-path').path
params = require('app/core/console_params').get()

module.exports = class Logger
	_endPoint: null
	_dir: null
	_streams: null

	constructor: (endPoint) ->
		@_endPoint = endPoint
		@_dir = "#{params.env}/#{endPoint}"
		@_streams =
			log:
				date: null
				stream: null

			error:
				date: null
				stream: null

	_createDir: (path) ->
		folders = path.split '/'
		path = rootPath

		_.each folders, (folder) ->
			path += "/#{folder}"

			if not fs.existsSync(path)
				fs.mkdirSync path

			return

	_getDateForFileName: ->
		now = new Date()
		year = now.getFullYear()
		month = now.getMonth() + 1
		day = now.getDate()
		return "#{year}_#{if month < 10 then '0' + month.toString() else month}_#{if day < 10 then '0' + day.toString() else day}"

	_getStream: (name) ->
		stream = @_streams[name]
		date = @_getDateForFileName()

		if stream.stream
			if stream.date is date
				return stream.stream

			stream.stream.end()
			stream.stream = null
			stream.date = null

		@_createDir "#{name}/#{@_dir}"
		stream.stream = fs.createWriteStream "#{rootPath}/#{name}/#{@_dir}/#{date}.log", flags: 'a'
		stream.date = date
		return stream.stream

	log: (text) ->
		stream = @_getStream 'log'
		stream.write "#{new Date()}: #{text}\n"

	error: (text) ->
		stream = @_getStream 'error'
		stream.write "\n\n#{new Date()}: #{text}\n"
