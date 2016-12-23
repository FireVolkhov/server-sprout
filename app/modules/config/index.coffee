rootPath = require('app-root-path').path
params = require 'app/core/console_params'
config = require 'app/core/config'

process.env.BLUEBIRD_W_FORGOTTEN_RETURN = 0

params
	.setParam 'env', 'NODE_ENV', ['--env', '-e'], 'dev'
	.setParam 'port', 'API_PORT', ['--port', '-p'], 3002
	.setParam 'coreMode', 'CORE_MODE', ['--core_mode', '-cm'], false
	.setParam 'redisHost', 'REDIS_HOST', ['--redis-host', '-rh'], 'redis'
	.setParam 'redisPort', 'REDIS_PORT', ['--redis-port', '-rp'], 6379
	.setParam 'run', 'RUN', ['--run', '-r'], null
	.setParam 'testing', 'TESTING', ['--testing', '-t'], false
	.parseParams process.env, process.argv

config
	.set 'express', requestLimit: '10mb'
	.set 'sequelize',
		connectString: 'postgres://docker:docker@db:5432/docker'
		connectOptions:
			logging: false
		define:
			timestamps: false
		defaultModel:
			capitalizeFirstLetter: true
			options:
				timestamp: false
				createdAt: false
				updatedAt: false
				freezeTableName: true

	.set 'pushNotification',
		gcm:
			id: 'AIzaSyC_mqb7kPUeds9VJ0MP-DaSuKxT6WlSlKE'

		apn:
			options:
				key: "#{rootPath}/app/modules/config/push_key.pem"
				cert: "#{rootPath}/app/modules/config/push_cert.pem"
				# Чтоб отправлял пуши
				production: true

	.set 'mail',
		smtpsConnectString: 'smtps://security-chat-dev:security-chat-dev*@smtp.yandex.ru'
		defaultOptions:
			from: '"Security chats" <security-chat-dev@yandex.ru>'
