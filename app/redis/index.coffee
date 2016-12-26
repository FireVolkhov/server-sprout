bluebird = require 'bluebird'
redis = require 'redis'

params = require('app/core/console_params').get()

redisClient = redis.createClient
	host: params.redisHost
	port: params.redisPort

bluebird.promisifyAll redis.RedisClient.prototype
bluebird.promisifyAll redis.Multi.prototype

pushInRoom = (room, value) ->
	value = if _.isObject(value) then JSON.stringify(value) else value

	@redisClient
		.multi()
		.rpush room, value
		.execAsync()

remInRoom = (room, value, count = 1) ->
	value = if _.isObject(value) then JSON.stringify(value) else value

	@redisClient
		.multi()
		.lrem room, count, value
		.execAsync()

clearList = (list) ->
	@redisClient
		.multi()
		.del list
		.execAsync()

getValue = (value) ->
	value = if _.isObject(value) then JSON.stringify(value) else value

	@redisClient
		.multi()
		.get value
		.execAsync()

getList = (list, start = 0, end = -1) ->
	@redisClient
		.multi()
		.lrange list, start, end
		.execAsync()

saddMember = (key, value) ->
	@redisClient
		.multi()
		.sadd key, value
		.execAsync()

sscanMember = (key, pattern) ->
	@redisClient
		.multi()
		.sscan key, 0, 'MATCH', pattern
		.execAsync()
		.then ([[n, data]]) -> data

sremMember = (key, value) ->
	@redisClient
		.multi()
		.srem key, value
		.execAsync()

delKey = (key) ->
	@redisClient
		.multi()
		.del key
		.execAsync()

module.exports =
	redisClient: redisClient
	pushInRoom: pushInRoom
	remInRoom: remInRoom
	clearList: clearList
	getValue: getValue
	getList: getList
	saddMember: saddMember
	sscanMember: sscanMember
	sremMember: sremMember
	delKey: delKey
