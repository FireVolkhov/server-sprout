Sequelize = require 'sequelize'
config = require('app/core/config').sequelize

module.exports = new Sequelize config.connectString, config.connectOptions
