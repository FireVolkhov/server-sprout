gcm = require 'node-gcm'
apn = require 'apn'

config = require('app/core/config').pushNotification
Logger = require 'app/core/Logger'

service =
	pushLoggerAndroid: new Logger 'push_notification/android'
	pushLoggerIos: new Logger 'push_notification/ios'

	_sendToGCM: (ids, data) ->
		if @settings.gcm?.id and ids?.length
			GCMSender = new gcm.Sender @settings.gcm.id, @settings.gcm.options

			data = _.extend data: data, @settings.gcm.dataDefaults

			messageGCM = new gcm.Message data
			messageGCM.addData 'msgcnt', @settings.gcm.msgcnt

			return new Promise (resolve, reject) =>
				GCMSender.send messageGCM, ids, @settings.gcm.retries, (err, result) =>
					@pushLoggerAndroid.log """\n
						✪✪✪ Android push ✪✪✪
						data: #{JSON.stringify data}
						tokens: #{JSON.stringify ids}
						#{if err then "☢☢☢ WITH ERROR: #{JSON.stringify err} ☢☢☢"}
						result: #{JSON.stringify result}
					\n"""

					if err
						console.error '☢☢☢\n ERROR in send push for Android : ', err, '\nIds: ', ids, '\n ☢☢☢'
						reject err
						return

					if result?.failure is 0
						resolve result.success
					else
						reject result?.results

	_sendToAPN: (ids, data) ->
		if ids?.length
			APNConnection = new apn.Connection @settings.apn.options
			messageAPN = new apn.Notification()
			_.extend messageAPN, @settings.apn.defaultData
			messageAPN.expiry = Math.floor(Date.now() / 1000) + @settings.apn.expiry
			messageAPN.badge = @settings.apn.badge
			messageAPN.sound = @settings.apn.defaultData.sound
			messageAPN.alert = data.title
			APNData = _.clone data
			delete APNData.title
			messageAPN.payload = APNData

			APNConnection.pushNotification messageAPN, ids

			logMessage = """\n
				✪✪✪ iOS push ✪✪✪
				data: #{JSON.stringify data}
				tokens: #{JSON.stringify ids}"""

			new Promise (resolve, reject) ->
				APNConnection.on 'completed', -> resolve()
				APNConnection.on 'error', -> reject new Error 'iosError'
				APNConnection.on 'socketError', -> reject new Error 'iosSocketError'
				APNConnection.on 'transmissionError', (errorCode, notification, device) ->
					deviceToken = device?.toString('hex')?.toUpperCase() or null;

					if (errorCode is 8)
						logMessage += "\n☢☢☢ WITH ERROR: APNS: Transmission error -- invalid token #{JSON.stringify errorCode}, #{JSON.stringify deviceToken} ☢☢☢"
					else
						logMessage += "\n☢☢☢ WITH ERROR: APNS: Transmission error #{JSON.stringify errorCode}, #{JSON.stringify deviceToken} ☢☢☢"

					reject new Error 'iosTransmissionError'
				APNConnection.on 'cacheTooSmall', -> reject new Error 'iosCacheTooSmall'

			.then ->
				logMessage += '\nresult: +'
				return true

			.catch (e) ->
				logMessage += "\n☢☢☢ WITH ERROR: #{e} ☢☢☢"
				console.error '☢☢☢\n ERROR in send push for iOS : ', e, '\nIds: ', ids, '\n ☢☢☢'
				return Promise.reject e

			.finally => @pushLoggerIos.log "#{logMessage}\n"

	settings:
		gcm:
			id: null
			dataDefaults:
				delayWhileIdle: false
				timeToLive: 4 * 7 * 24 * 3600 # 4 weeks
				retries: 4
			# Custom GCM request options https://github.com/ToothlessGear/node-gcm#custom-gcm-request-options
			options: {}

		apn:
			gateway: 'gateway.sandbox.push.apple.com'
			defaultData:
				expiry: 4 * 7 * 24 * 3600 # 4 weeks
				sound: 'ping.aiff'
			# See all available options at https://github.com/argon/node-apn/blob/master/doc/connection.markdown
			options: {}

	send: (tokens, data) ->
		if tokens.android.length is 0 and tokens.ios.length is 0
			return Promise.reject()

		GCMPromise = @_sendToGCM tokens.android or [], data
		APNPromise = @_sendToAPN tokens.ios or [], data

		return Promise.all [GCMPromise, APNPromise]

_.each ['gcm', 'apn'], (serviceName) ->
	if config[serviceName]
		service.settings[serviceName] = _.extend service.settings[serviceName], config[serviceName]
	else
		delete service.settings[serviceName]
	return

module.exports = service
