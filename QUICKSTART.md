# Quick Start Guide


## Run the pipeline to build the pipeline image
1. Clone the repo to Gitlab
2. Run the default pipeline

## Set up the config file with AWS account / IAM imfo : CloudFormation
3. Create AWS user with assume role of the pipeline policy only
4. Create AWS access key and secret key for the above user
5. IAM role for pipeline: 
6. S3 bucket for terraform state remote backend

## Setup pipeline variables at group level or repo level.
### Add the following variable to 
7. CI1_AWS_ACCESS_KEY
8. CI1_AWS_SECRET_KEY
9. CI1_AWS_ASSUME_ROLE_ARN
10. CI1_AWS_DEFAULT_REGION
11. CI1_AWS_TFSTATE_S3_BUCKET
12. CI1_AWS_TFSTATE_S3_KEY
13. GITLAB_API_TOKEN



## How to use example