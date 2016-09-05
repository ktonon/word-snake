#!/usr/bin/env bash
set -e

if [ ! $CIRCLE_SHA1 = "" ] ; then
    echo 'Using SHA1 from circleci'
else
    export CIRCLE_SHA1=$(git rev-parse HEAD)
fi

# Define environment variables used by other scripts
export DOCKER_ACCOUNT=ktonon
export SERVICE=word-snake

# Derived
export DOCKER_IMAGE=$DOCKER_ACCOUNT/$SERVICE
export DOCKER_TAG=$DOCKER_IMAGE:$CIRCLE_SHA1
