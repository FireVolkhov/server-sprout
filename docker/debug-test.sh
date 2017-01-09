#!/usr/bin/env bash
#sh "`dirname $0`/../node_modules/.bin/mocha" "`dirname $0`/../**/*.dev.spec.coffee" --compilers coffee:coffee-script/register
source "`dirname $0`/../env.sh"
mocha "`dirname $0`/../**/*.dev.spec.coffee" --compilers coffee:coffee-script/register
#for n in {1..1000..1000}; do   # start 100 fetch loops
#        for i in `eval echo {$n..$((n+999))}`; do
#                echo "club $i..."
#                curl -s "http://localhost:80/v1/user/login" -d "{\"login\":\"autotest1\"}" > /dev/null
#        done &
#        wait
#done
