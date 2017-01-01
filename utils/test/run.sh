#!/usr/bin/env bash
source "`dirname $0`/../../env.sh"

export COMPOSE_CONVERT_WINDOWS_PATHS=1
docker-compose -f "`dirname $0`/../../docker/docker-compose-test.yml" --project-name testrun up -d --build
ID="`docker ps | perl -ne 'if(m/([^\s]*)\s+unit6\/test-${PROJECT}/) {print $1;}'`"
echo "Connect to container $ID"
#docker exec -it "$ID" ./docker/run-test.sh
docker exec -it testrun_web_1 ./docker/run-test.sh

#echo "Docker logs"
#docker logs testrun_web_1
#echo "Docker logs End"

docker-compose -f "`dirname $0`/../../docker/docker-compose-test.yml" --project-name testrun stop db redis web
docker-compose -f "`dirname $0`/../../docker/docker-compose-test.yml" --project-name testrun rm -f db redis web
