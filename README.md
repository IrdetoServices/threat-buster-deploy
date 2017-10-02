# Threat Buster Janus

This project contains helper tools to build docker images for Janus Graph DB for [Threat Buster](https://github.com/IrdetoServices/threat-buster)

# Local Usage

## Local Settings

If you are using Pycharm/IntelliJ you can open the root project. It will not automatically handle the submodules properly - you should add each of
them as a module and VCS root.

This project uses Git Submodules. When working using Gitflow workflow you need to do it per submodule. Each module versions seperatly. When you've completed you commit the changes on the top level module. For a guide to Git Submodules see https://git-scm.com/book/en/v2/Git-Tools-Submodules

Each sub module will have seperate building/environment instructions. The top level module uses Python VirtualEnvs to configure it follow notes below.


## Local Janus DB

```
git clone -recursive https://github.com/IrdetoServices/threat-buster-janus
cd threat-buster-janus
mkvirtualenv threat-buster-janus -P python3
pip install -r requirements.txt
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
# SSH Access to VPC

By default there is no SSH access to the VPC. This is a good thing for security and maintaining CI/CD as access tends to result in issues...

If you need temporary access the simplest way is to enable it on the EB Console for the instances. It will cycle the instances provisioning SSH.
    
# Pre-reqs

* Maven 
* Java 8
* Python 3.6
