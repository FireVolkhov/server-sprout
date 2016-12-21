configGetter = require 'app/core/config_getter'

module.exports = if configGetter.onKeyTesting then (20 * 1000) else (60 * 1000)