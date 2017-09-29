#!/usr/bin/env bash

echo "Script requires working and configured AWS CLI"

while getopts c OPTION
do	case "$OPTION" in
	c)	CLEAN=true;;
	[?])	printf "Usage: $0 [-c]"
		exit 1;;
	esac
done

source functions.sh

# Log into Docker with AWS credentials
COMMAND=`aws ecr get-login --no-include-email --region $REGION`
$COMMAND

build_docker_image

GIT_HEAD=`git rev-parse HEAD`

pushd janus-docker
docker build . -t janusdocker:latest -t janusdocker:v$GIT_HEAD
popd

docker tag janusdocker:latest $REPO_URL/$REPO:latest
docker tag janusdocker:v$GIT_HEAD $REPO_URL/$REPO:v$GIT_HEAD
docker push $REPO_URL/$REPO:latest
docker push $REPO_URL/$REPO:v$GIT_HEAD

