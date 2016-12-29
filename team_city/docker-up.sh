#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

source "$SCRIPT_DIR/../env.sh"
export DOCKER_PORT="3002"

docker-compose -f "$SCRIPT_DIR/../docker/docker-compose.yml" --project-name "$PROJECT" up -d
