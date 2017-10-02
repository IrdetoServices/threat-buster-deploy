#!/usr/bin/env bash -x

echo "Running local dynamo and local janus DB - press Control-C to exit"
source functions.sh

build_docker_image

docker-compose -f dynamodb-janusgraph-storage-backend/src/test/resources/docker-compose.yml up
