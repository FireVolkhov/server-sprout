#!/usr/bin/env bash
docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/team-city-test-/) {print $1;}'`"
echo "Connect to container $ID"
docker exec -i -t "$ID" ./docker/team-city-test.sh

echo "Stop container $ID"
docker stop "$ID"
echo "Stop other containers"
docker-compose -f "`dirname $0`/../docker/docker-compose-dev.yml" stop db redis

echo "Remove container $ID"
docker rm "$ID"
echo "Remove other containers"
docker-compose -f "`dirname $0`/../docker/docker-compose-dev.yml" rm -f db redis
