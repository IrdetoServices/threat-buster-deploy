#!/usr/bin/env bash

echo "Script requires working and configured AWS CLI"

while getopts n:c: o
do	case "$o" in
	n)	NAME="$OPTARG";;
	[?])	print >&2 "Usage: $0 [-n] Name"
		exit 1;;
	esac
done

source docker_image.sh

COMMAND=`aws ecr get-login --no-include-email --region eu-west-2`
$COMMAND

build_docker_image

docker tag dynamodb-janusgraph/server:latest 187415578575.dkr.ecr.eu-west-2.amazonaws.com/dynamodb-janusgraph:latest
docker push 187415578575.dkr.ecr.eu-west-2.amazonaws.com/dynamodb-janusgraph:latest

aws cloudformation create-stack --stack-name janus-tables-$NAME --template-body file://dynamodb-janusgraph-storage-backend/dynamodb-janusgraph-tables-multiple.yaml --region eu-west-2 --capabilities CAPABILITY_IAM
aws cloudformation create-stack --stack-name ecs-$NAME --template-body file://cloudformation/ecs.yaml --region eu-west-2 --capabilities CAPABILITY_IAM
