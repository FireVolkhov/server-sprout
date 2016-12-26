#!/usr/bin/env bash
node "`dirname $0`/../../node_modules/sequelize-cli/bin/sequelize" db:migrate:undo --migrations-path "`dirname $0`/../../app/modules/migrations" --config "`dirname $0`/../../app/modules/config/config.json" --coffee true
