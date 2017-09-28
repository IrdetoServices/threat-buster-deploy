#!/usr/bin/env bash

echo "Script requires working and configured AWS CLI"

while getopts cr:u: OPTION
do	case "$OPTION" in
	c)	CLEAN=true;;
	r)  REPO="$OPTARG";;
	u)  REPO_URL="$OPTARG";;
	[?])	printf "Usage: $0 -r REPO -u REPO_URL"
		exit 1;;
	esac
done

source functions.sh

COMMAND=`aws ecr get-login --no-include-email --region eu-west-2`
$COMMAND

build_docker_image

docker tag dynamodb-janusgraph/server:latest $REPO_URL/$REPO:latest
docker push $REPO_URL/$REPO:latest

echo "To Run Task Run"
