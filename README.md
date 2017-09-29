# Threat Buster Janus

This project contains helper tools to build docker images for Janus Graph DB for [Threat Buster](https://github.com/IrdetoServices/threat-buster)

# Local Usage

```
mkvirtualenv threat-buster-janus -P python3
pip install -r requirements.txt
git clone -recursive
./localdev.sh
```

# AWS Usage

## Pre Reqs
* Working AWS Account and CLI
* Install [cfn_create_or_update](https://github.com/widdix/cfn-create-or-update)

## One Off Steps for supporting infrastructure required to run the main CloudFormation
* Create an ECR Repo 
    ``` cfn-create-or-update --stack-name threat-buster-repo --template-body file://cloudformation/Infrastructure.yaml --region eu-west-2```
* Wait for CF to complete and get the ECR Repository
    ``` aws cloudformation describe-stacks --region eu-west-2 --stack-name threat-buster-repo ```
* Create a TLS Certificate for you public URL in AWS Cert Manager in your region (see AWS docs on how to do this)
* Create local_parameters.sh containing using outputs of the CF as parameters
    ``` 
    STACK_NAME=PICK_A_UNIQUE_STACK_NAME
    REPO=YOUR_REPO
    REPO_URL=YOUR_REPO_URL
    REGION=YOUR_REGION
    SCRIPT_BUCKET=YOUR_SCRIPT_BUCKET
    CERTIFICATE_ARN=YOUR_CERT_ARN
    ```
* Deploy docker images / scripts
    ```
    ./aws_docker_deploy.sh
    ./aws_script_deploy.sh
    ```
* Deploy CF template
    ```
    ./aws_cf_deploy.sh
    ```
The environment will now create!

* Connect EB up
    ``` 
    eb init 
    ```    
    (note if you have already used eb remove .elasticbeanstalk)

* Select the application CF created
    ``` 
    eb list 
    eb use OUTPUT_OF_LAST_COMMAND
    eb deploy
    ```
    
# Pre-reqs

* Maven 
* Java 8
* Python 3.6
