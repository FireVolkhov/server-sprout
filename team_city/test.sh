#!/usr/bin/env bash
echo "`dirname $0`/../env.sh"
source "`dirname $0`/../env.sh"

docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/team-city-test-$PROJECT/) {print $1;}'`"
echo "Connect to container $ID"
docker exec -i "$ID" ./docker/team-city-test.sh

echo "Docker logs"
docker logs teamcity_web_1
echo "Docker logs End"

docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity stop db redis web
docker-compose -f "`dirname $0`/../docker/docker-compose-team-city.yml" --project-name teamcity rm -f db redis web
