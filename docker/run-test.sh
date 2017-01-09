#!/usr/bin/env bash
source "`dirname $0`/../env.sh"
export GOROOT=$HOME/go
export GOPATH=/usr/local/go
mocha "`dirname $0`/../**/*.spec.coffee" --compilers coffee:coffee-script/register
