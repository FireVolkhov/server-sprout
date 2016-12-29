#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

source "$SCRIPT_DIR/../env.sh"

FULL_VERSION="${VERSION}.0.0.${BUILD_NUMBER:-99}"
IMAGE="unit6/${PROJECT}"
ID=$(docker build  -t ${IMAGE}:${FULL_VERSION} -t ${IMAGE}:latest -t $192.168.0.5:5000/{IMAGE}:latest .  | tail -1 | sed 's/.*Successfully built \(.*\)$/\1/')

#docker tag "$IMAGE" "192.168.0.5:5000/$IMAGE"
docker push "192.168.0.5:5000/$IMAGE:latest"
