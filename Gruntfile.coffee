require './app/core/require'
require './app/core/Promise'
global._ = require 'lodash'

module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-mocha-test'

	grunt.initConfig
		mochaTest:
			test:
				options:
					reporter: 'spec'
					require: ['coffee-script/register']

				src: ['app/**/*.spec.coffee']

			debug_test:
				options:
					reporter: 'spec'
					require: ['coffee-script/register']

				src: ['app/**/*.dev.spec.coffee']

	grunt.registerTask 'test', 'mochaTest:test'
	grunt.registerTask 'debug_test', 'mochaTest:debug_test'
	grunt.registerTask 'default', 'test'
