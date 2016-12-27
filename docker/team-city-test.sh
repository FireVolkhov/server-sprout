#!/usr/bin/env bash
mocha "`dirname $0`/../**/*.spec.coffee" --compilers coffee:coffee-script/register --reporter mocha-teamcity-reporter dev
