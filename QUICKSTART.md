# Quick Start Guide


## Run the pipeline to build the pipeline image
1. Clone the repo to Gitlab
2. Run the default pipeline

## Set up the config file with AWS account / IAM imfo : CloudFormation
3. Create AWS user with assume role of the pipeline policy only
4. Create AWS access key and secret key for the above user

## If multi-accounts setup , create the following for each account.
[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=InfraPipeSetup&templateURL=https://shiftsecurityleft-infrapipe-cf.s3.amazonaws.com/infrapipe/latest/role_setup.yaml

5. IAM role for pipeline: must trust above IAM user
6. Add IAM role ARN to SSM security/pipeline/<ENV>/AWS_ASSUME_ROLE_ARN
6. S3 bucket for terraform state remote backend
11. Add above S3 bucket name to SSM security/pipeline/<ENV>/AWS_TFSTATE_S3_BUCKET
11. Add above S3 key to SSM security/pipeline/<ENV>/AWS_TFSTATE_S3_KEY (hardcode terraform.tfstate)

## Setup pipeline variables at group level or repo level.
### Add the following variable to 
7. CI1_AWS_ACCESS_KEY
8. CI1_AWS_SECRET_KEY
10. CI1_AWS_DEFAULT_REGION

## How to use example
1. create a tf-<ENV>-<description> branch