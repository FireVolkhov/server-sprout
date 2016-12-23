#!/usr/bin/env bash
export COMPOSE_CONVERT_WINDOWS_PATHS=1
docker-compose -f "`dirname $0`/../docker/docker-compose-dev.yml" up -d
