#!/usr/bin/env bash

echo "Running local local neo4j"
source functions.sh

docker run \
    --publish=7474:7474 --publish=7687:7687 \
    --volume=$HOME/neo4j/data:/data \
    --volume=$HOME/neo4j/logs:/logs \
    --env NEO4J_AUTH=neo4j/threat-buster \
    neo4j:enterprise