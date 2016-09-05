#!/usr/bin/env bash
set -e

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/env.sh

npm run build
docker build -t $DOCKER_TAG .
docker tag $DOCKER_TAG $DOCKER_IMAGE:latest
