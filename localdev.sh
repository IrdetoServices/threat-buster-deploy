#!/usr/bin/env bash

echo "Running local dynamo and local janus DB - press Control-C to exit"
source docker_image.sh

build_docker_image

docker-compose -f src/test/resources/docker-compose.yml up

popd