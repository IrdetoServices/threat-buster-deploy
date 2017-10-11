#!/usr/bin/env bash

if [ -f local_parameters.sh ] ; then
    source local_parameters.sh
else
    echo "See Readme - local_paramters.sh needed"
    exit 1
fi


function copy_cloud_formations {

    aws s3 cp cloudformation/ecs.yaml s3://$SCRIPT_BUCKET/ecs.yaml
    aws s3 cp cloudformation/ecs_task_neo4j.yaml s3://$SCRIPT_BUCKET/ecs_task_neo4j.yaml
    aws s3 cp cloudformation/random_input.yaml s3://$SCRIPT_BUCKET/random_input.yaml
    aws s3 cp cloudformation/vpc.yaml s3://$SCRIPT_BUCKET/vpc.yaml
    aws s3 cp cloudformation/rds.yaml s3://$SCRIPT_BUCKET/rds.yaml
    rm cloudformation/lambda_function.zip
    zip -Dj cloudformation/lambda_function.zip cloudformation-random-string/lambda_function.py
    aws s3 cp cloudformation/lambda_function.zip s3://$SCRIPT_BUCKET/lambda_function.zip

}

