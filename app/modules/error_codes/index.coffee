module.exports =
	OLD_VERSION:
		CODE: 1
		MESSAGE: 'This application version is too old. Please download the latest version.'

	NOT_FOUND_USER:
		CODE: 2
		MESSAGE: 'User not found.'

	BAD_LOGIN_PASS:
		CODE: 3
		MESSAGE: 'User name or password is incorrect.'

	MANY_REQUESTS:
		CODE: 4
		MESSAGE: 'Too many requests.'

	USER_NOT_FOUND:
		CODE: 6
		MESSAGE: (message = '') -> "Invalid user ID.#{message}"

	INVALID_REQUEST:
		CODE: 101
		MESSAGE: (message = '') -> "Invalid request: #{message}."

	NOT_FOUND_MODEL:
		CODE: 102
		MESSAGE: (message = '') -> "Model not found: #{message}."

	INTERNAL_SERVER:
		CODE: 500
		MESSAGE: 'Internal server error'
