#!/usr/bin/env bash
source "`dirname $0`/../env.sh"
mocha "`dirname $0`/../**/*.spec.coffee" --compilers coffee:coffee-script/register --reporter mocha-teamcity-reporter dev
