#!/usr/bin/env bash
node "`dirname $0`/../../node_modules/sequelize-cli/bin/sequelize" migration:create --migrations-path "`dirname $0`/../../app/modules/migrations" --config "`dirname $0`/../../app/modules/config/config.json" --coffee true --name $1
git add "`dirname $0`/../../app/modules/migrations/*$1.coffee"
