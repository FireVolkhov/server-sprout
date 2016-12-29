#!/usr/bin/env bash
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "Script dir: $SCRIPT_DIR"
source "$SCRIPT_DIR/../env.sh"

docker-compose -f "$SCRIPT_DIR/../docker/docker-compose-team-city.yml" --project-name teamcity up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/team-city-test-$PROJECT/) {print $1;}'`"
echo "Connect to container $ID"
docker exec -i "$ID" ./docker/team-city-test.sh

echo "Docker logs"
docker logs teamcity_web_1
echo "Docker logs End"

docker-compose -f "$SCRIPT_DIR/../docker/docker-compose-team-city.yml" --project-name teamcity stop db redis web
docker-compose -f "$SCRIPT_DIR/../docker/docker-compose-team-city.yml" --project-name teamcity rm -f db redis web
