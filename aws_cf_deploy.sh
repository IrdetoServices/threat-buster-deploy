#!/usr/bin/env bash

source functions.sh

cfn-create-or-update --stack-name $STACK_NAME --template-body file://cloudformation/wrapper.yaml \
    --region $REGION --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters \
    ParameterKey=ScriptBucket,ParameterValue=$SCRIPT_BUCKET \
    ParameterKey=CertificateARN,ParameterValue=$CERTIFICATE_ARN \
    ParameterKey=Image,ParameterValue=$REPO_URL/$REPO:latest \
    ParameterKey=KeyName,ParameterValue=$KEY_NAME --disable-rollback

