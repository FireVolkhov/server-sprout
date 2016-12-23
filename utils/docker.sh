#!/usr/bin/env bash
docker-compose -f "`dirname $0`/../docker/docker-compose.yml" up -d
