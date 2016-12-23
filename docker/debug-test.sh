#!/usr/bin/env bash
#sh "`dirname $0`/../node_modules/.bin/mocha" "`dirname $0`/../**/*.dev.spec.coffee" --compilers coffee:coffee-script/register
mocha "`dirname $0`/../**/*.dev.spec.coffee" --compilers coffee:coffee-script/register
