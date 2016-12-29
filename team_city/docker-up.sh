#!/usr/bin/env bash
source "`dirname $0`/../env.sh"
export DOCKER_PORT="3002"

docker-compose -f "`dirname $0`/../docker/docker-compose.yml" up -d --project-name "$PROJECT"
