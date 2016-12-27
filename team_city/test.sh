#!/usr/bin/env bash
docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/team-city-test-server-sprout/) {print $1;}'`"
echo "Connect to container $ID"
docker exec -i "$ID" ./docker/team-city-test.sh

echo "Stop other containers"
docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity stop db redis web

echo "Remove other containers"
docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity rm -f db redis web