# Quick Start Guide

1. Clone [this](https://github.com/shiftsecurityleft/infrapipe) Github repo to a project in [Gitlab](https://gitlab.com)
  - a. Go to New Project -> Import Project -> Repo by URL
  ![](images/quickstart/step1a-import-project.png)
  - b. Type in Repository URL: https://github.com/shiftsecurityleft/infrapipe.git
  - c. Click Create Project
2. Run the pipeline to build the base Docker image.
  - a. Go to CI/CD -> Pipelines -> Run Pipeline
  - b. Run Pipeline for the `master` branch
3. Deploy the setup CloudFormation stack to create necessary AWS resources
  - a. Click [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=InfraPipeSetup&templateURL=https://shiftsecurityleft-infrapipe-cf.s3.amazonaws.com/infrapipe/branch/master/cf-templates/infrapipe-setup.cfn.yaml) to launch the preconfigured CF template in your AWS account
  - b. Click Create Stack
4. Manually generate an access key

## Setup pipeline variables at group level or repo level.
### Add the following variable to 
7. CI1_AWS_ACCESS_KEY
8. CI1_AWS_SECRET_KEY
10. CI1_AWS_DEFAULT_REGION

## How to use example
1. create a tf-<ENV>-<description> branch
