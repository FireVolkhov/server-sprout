#!/usr/bin/env bash
export COMPOSE_CONVERT_WINDOWS_PATHS=1
export EXTERNAL_PORT=3002
export PROJECT_LOCATION=/c/Projects/server-sprout/
docker-compose up -d
