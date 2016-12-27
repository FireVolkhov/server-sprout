#!/usr/bin/env bash
export COMPOSE_CONVERT_WINDOWS_PATHS=1
docker-compose -f "`dirname $0`/../../docker/docker-compose-dev.yml" --project-name testrun up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/test-server-sprout/) {print $1;}'`"
echo "Connect to container $ID"
docker exec -i "$ID" ./docker/run-test.sh

echo "Stop other containers"
docker-compose -f "`dirname $0`/../../docker/docker-compose-dev.yml" --project-name testrun stop db redis web

echo "Remove other containers"
docker-compose -f "`dirname $0`/../../docker/docker-compose-dev.yml" --project-name testrun rm -f db redis web
