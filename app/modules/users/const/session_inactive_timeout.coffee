params = require('app/core/console_params').get()

module.exports = if params.testing then (20 * 1000) else (60 * 1000)