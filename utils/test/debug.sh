#!/usr/bin/env bash
sh "`dirname $0`/../build-docker-dev.sh"
docker exec -i -t "`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/server/) {print $1;}'`" ./docker/debug-test.sh
