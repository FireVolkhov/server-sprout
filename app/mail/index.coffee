nodemailer = require 'nodemailer'
config = require('app/core/config').mail
Logger = require 'app/core/services/logger'


transporter = null
logger = new Logger 'mail/send'

initTransporter = ->
	if not transporter
		transporter = nodemailer.createTransport config.smtpsConnectString

send = (data) ->
	data = _.extend _.clone(config.defaultOptions), data

	return new Promise (resolve, reject) ->
		if not data.to
			return reject new Error 'Need fill field `to`'

		if not data.subject
			return reject new Error 'Need fill field `subject`'

		if not data.text and not data.html and not data.attachments
			return reject new Error 'Need fill fields `text` or `html` or `attachments`'

		initTransporter()

		transporter.sendMail data, (error, info) ->
			logger.log """\n
					✉✉✉ Mail send ✉✉✉
					data: #{JSON.stringify data}
					to: #{data.to}
					#{if error then "☢☢☢ WITH ERROR: #{JSON.stringify error} ☢☢☢"}
					result: #{JSON.stringify info?.response}
				\n"""

			if error
				reject new Error error
				console.error error

			else
				resolve info?.response

module.exports =
	send: send
