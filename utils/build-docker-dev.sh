#!/usr/bin/env bash
source "`dirname $0`/../env.sh"

export COMPOSE_CONVERT_WINDOWS_PATHS=1
docker-compose -f "`dirname $0`/../docker/docker-compose-dev.yml" build
docker-compose -f "`dirname $0`/../docker/docker-compose-dev.yml" up -d
