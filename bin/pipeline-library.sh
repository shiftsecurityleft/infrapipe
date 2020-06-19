#!/bin/bash

tlog() {
  action=$1 && shift
  case $action in
    DEBUG)  [[ $LOGGER_LVL =~ (DEBUG) ]]           && echo "$( date "+${LOGGER_FMT}" ) - DEBUG - $@" 1>&2 ;;
    INFO)   [[ $LOGGER_LVL =~ (DEBUG|INFO) ]]      && echo "$( date "+${LOGGER_FMT}" ) - INFO - $@" 1>&2;;
    WARN)   [[ $LOGGER_LVL =~ (DEBUG|INFO|WARN) ]] && echo "$( date "+${LOGGER_FMT}" ) - WARN - $@" 1>&2 ;;
    ERROR)  [[ ! $LOGGER_LVL =~ (NONE) ]]          && echo "$( date "+${LOGGER_FMT}" ) - ERROR - $@" 1>&2 ;;
  esac
  true
}
export -f tlog

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    tlog ERROR "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
  else
    tlog ERROR "Error on or near line ${parent_lineno}; exiting with status ${code}"
  fi
  exit "${code}"
}
export -f error

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}
export -f trim

mapBitbucketPipelineVars() {
  # Check to make sure this is run in BITBUCKET pipeline by checking BITBUCKET_REPO_SLUG var exists.
  if [[ ! -z "${BITBUCKET_REPO_SLUG}" ]]; then
    export TF_VAR_SCM_TOOL=BITBUCKET
    export TF_VAR_CI_TOOL=BITBUCKET
    export TF_VAR_MANIFEST_REPO=app-manifest
    export TF_VAR_MANIFEST_VER=latest
    export TF_VAR_AWS_CRED_SSM_PATH=security/pipeline
    export TF_VAR_CI_AWSENV=CI1
    export TF_VAR_REPO_BRANCH=${BITBUCKET_BRANCH}
    export TF_VAR_REPO_TAG=${BITBUCKET_TAG}
    export TF_VAR_REPO_NAME=${BITBUCKET_REPO_SLUG}
    export TF_VAR_REPO_WORKSPACE=${BITBUCKET_WORKSPACE}
    export TF_VAR_REPO_URL=${BITBUCKET_GIT_HTTP_ORIGIN}
    export TF_VAR_REPO_COMMIT_HASH=${BITBUCKET_COMMIT}
    export TF_VAR_PIPELINE_BUILD_URL=https://bitbucket.org/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}/addon/pipelines/home/results/${BITBUCKET_BUILD_NUMBER}
    export TF_VAR_PIPELINE_BUILD_NUM=${BITBUCKET_BUILD_NUMBER}
    export TF_VAR_PIPELINE_BUILD_DATETIME=$(date -Iseconds)
    export TF_VAR_REPO_COMMIT_AUTHOR=$(git log -1 --pretty=format:'%ae' ${TF_VAR_REPO_COMMIT_HASH:0:7})
    export TF_VAR_REPO_COMMIT_DATETIME=$(git log -1 --pretty=format:'%aI' ${TF_VAR_REPO_COMMIT_HASH:0:7})
    #export TF_VAR_PIPELINE_BUILD_URL=https://bitbucket.org/${BITBUCKET_WORKSPACE}/${BITBUCKET_REPO_SLUG}/addon/pipelines/home#!/results/${BITBUCKET_BUILD_NUMBER}
    export TF_VAR_APP_BRANCH_UUID="$(echo ${TF_VAR_REPO_NAME}-${TF_VAR_REPO_BRANCH} | md5sum | cut -c 1-7)"
    # TF_VAR_AWS_CRED_MODE
    #   ENV_VARS = read <ENV>_AWS_* vars from Bitbucket org env vars, 
    #   SSM_VARS = read /devops/<ENV>/AWS_* vars from CI account, 
    #   SSM_CA_ROLES = read /devops/<ENV>/AWS_CROSSACCOUNT_ROLE from CI account
    export TF_VAR_AWS_CRED_MODE=SSM_CA_ROLES

    tlog DEBUG '============== show env ==================='
    tlog DEBUG "$( ( set -o posix ; set ) | grep TF_VAR_ )"
    tlog DEBUG '-------------------------------------------'

    # Add ENV vars starting with TF_VAR_ without TF_VAR_
    OLD_IFS=$IFS
    IFS==; while read KEY VALUE; do
      export ${KEY//TF_VAR_/}=${VALUE}
    done < <( ( set -o posix ; set ) | grep TF_VAR_ )
    IFS=$OLD_IFS

    # Add ENV vars starting with TF_VAR_ as TAGS without TF_VAR_
    #TAGS=""
    #IFS==; while read KEY VALUE; do
    #  TAGS="$TAGS\n${KEY//TF_VAR_/} = \"${VALUE}\""
    #done < <( ( set -o posix ; set ) | grep TF_VAR_ )
    #export TAGS

    # Set Git credential for Terraform Module Source access without having to provide the credential in the URL. 
    export REPO_USERNAME=${BITBUCKET_USERNAME}
    export REPO_PASSWORD=${BITBUCKET_PASSWORD}

    git config --global credential.helper "store --file $HOME/.my-credentials"
    printf "host=bitbucket.org\nusername=${REPO_USERNAME}\npassword=${REPO_PASSWORD}\nprotocol=https\n" | git credential-store --file $HOME/.my-credentials store
    echo "machine api.bitbucket.org login ${REPO_USERNAME} password ${REPO_PASSWORD}" > $HOME/.netrc

    # The following vars's value are dynamic.  Therefore "\$"
    #export BITBUCKET_API="https://\${BB_AUTH_STRING}@api.bitbucket.org/2.0/repositories/\${BITBUCKET_WORKSPACE}"
    export BITBUCKET_API="https://${REPO_USERNAME}:${REPO_PASSWORD}@api.bitbucket.org/2.0/repositories/\${REPO_WORKSPACE}"
    export BUILD_STATUS_URL="${BITBUCKET_API}/${REPO_NAME}/commit/${REPO_COMMIT_HASH}/statuses/build"
    export FAMILY_YML="${BITBUCKET_API}/${MANIFEST_REPO}/src/\${MANIFEST_VER}/family.yml"
    export MANIFEST_YML="${BITBUCKET_API}/${MANIFEST_REPO}/src/\${MANIFEST_VER}/\${APP_FAMILY}/manifest.yml"
  else
    tlog ERROR "This is NOT Bitbucket pipeline or missing Bitbucket pipeline variables for some reason if it is."
    exit 1
  fi
}
export -f mapBitbucketPipelineVars

mapGitlabPipelineVars() {
  if [[ ! -z "${GITLAB_CI}" ]]; then
    export TF_VAR_SCM_TOOL=GITLAB
    export TF_VAR_CI_TOOL=GITLAB
    export TF_VAR_MANIFEST_REPO=app-manifest
    export TF_VAR_MANIFEST_VER=latest
    export TF_VAR_AWS_CRED_SSM_PATH=security/pipeline
    export TF_VAR_CI_AWSENV=CI1
    export TF_VAR_REPO_BRANCH=${CI_COMMIT_REF_NAME}
    export TF_VAR_REPO_TAG=${CI_COMMIT_TAG}
    export TF_VAR_REPO_NAME=${CI_PROJECT_NAME}
    export TF_VAR_REPO_WORKSPACE=${CI_PROJECT_NAMESPACE}
    export TF_VAR_REPO_URL=${CI_PROJECT_URL}
    export TF_VAR_REPO_COMMIT_HASH=${CI_COMMIT_SHA}
    export TF_VAR_PIPELINE_BUILD_URL=${CI_PIPELINE_URL}
    export TF_VAR_PIPELINE_BUILD_NUM=${CI_PIPELINE_ID}
    export TF_VAR_PIPELINE_BUILD_DATETIME=$(date -Iseconds)
    export TF_VAR_REPO_COMMIT_AUTHOR=
    export TF_VAR_REPO_COMMIT_DATETIME=
    export TF_VAR_APP_BRANCH_UUID="$(echo ${TF_VAR_REPO_NAME}-${TF_VAR_REPO_BRANCH} | md5sum | cut -c 1-7)"
    # TF_VAR_AWS_CRED_MODE
    #   ENV_VARS = read <ENV>_AWS_* vars from Github Group env vars, 
    #   SSM_VARS = read /devops/<ENV>/AWS_* vars from CI account, 
    #   SSM_CA_ROLES = read /devops/<ENV>/AWS_CROSSACCOUNT_ROLE from CI account
    export TF_VAR_AWS_CRED_MODE=SSM_CA_ROLES

    tlog DEBUG '============== show env ==================='
    tlog DEBUG "$( ( set -o posix ; set ) | grep TF_VAR_ )"
    tlog DEBUG '-------------------------------------------'

    # Add ENV vars starting with TF_VAR_ without TF_VAR_
    OLD_IFS=$IFS
    IFS==; while read KEY VALUE; do
      export ${KEY//TF_VAR_/}=${VALUE}
    done < <( ( set -o posix ; set ) | grep TF_VAR_ )
    IFS=$OLD_IFS

    export REPO_USERNAME=gitlab-ci-token
    export REPO_PASSWORD=${CI_JOB_TOKEN}

    git config --global credential.helper "store --file $HOME/.my-credentials"
    echo -e "host=gitlab.com\nusername=${REPO_USERNAME}\npassword=${REPO_PASSWORD}\nprotocol=https\n" | git credential-store --file $HOME/.my-credentials store
    echo -e "machine gitlab.com\nlogin ${REPO_USERNAME}\npassword ${REPO_PASSWORD}" > $HOME/.netrc

    # The following vars's value are dynamic.  Therefore "\$"
    export GITLAB_API="https://gitlab.com/api/v4/projects/\${REPO_WORKSPACE}"
    export GITLAB_URL="https://gitlab.com/\${REPO_WORKSPACE}"
    export BUILD_STATUS_URL="${GITLAB_API}/${REPO_NAME}/statuses/${REPO_COMMIT_HASH}"
    export FAMILY_YML="${GITLAB_URL}/${MANIFEST_REPO}/raw/\${MANIFEST_VER}/family.yml"
    export MANIFEST_YML="${GITLAB_URL}/${MANIFEST_REPO}/raw/\${MANIFEST_VER}/\${APP_FAMILY}/manifest.yml"
  else
    tlog ERROR "This is NOT Gitlab pipeline or missing Gitlab pipeline variables for some reason if it is."
    exit 1
  fi
}
export -f mapGitlabPipelineVars

getFamilies() {
  if [[ -z ${FAMILY_YML_CACHE} ]]; then
    export FAMILY_YML_CACHE=$(eval "curl -sSL ${FAMILY_YML}")
  fi
  echo "${FAMILY_YML_CACHE}"
}
export -f getFamilies

getFamilyName() {
  getFamilies | yq -r '.families[] | select(.repos[].repo == env.REPO_NAME) | .family'
}
export -f getFamilyName

getSsmPath() {
  getFamilies | yq -r '.families[] | select(.repos[].repo == env.REPO_NAME) | .ssm_path'
}
export -f getSsmPath

# Usage: loadManifest [app_family]
#         app_family: one of slate | ingestion | data
loadManifest() {
  APP_FAMILY=$(getFamilyName)

  if [[ ! -z ${APP_FAMILY} ]]; then
    if [[ -z ${MANIFEST_YML_CACHE} ]]; then
      export MANIFEST_YML_CACHE=$(eval "curl -sSL ${MANIFEST_YML}")
    fi
    echo "${MANIFEST_YML_CACHE}"
  fi
}
export -f loadManifest

getAppNameBasedOnRepoName() {
  getFamilies | yq -r '.families[].repos[] | select(.repo == env.REPO_NAME) | .app_prefix'
}
export -f getAppNameBasedOnRepoName

getBranchManifest() {
  MANIFEST=$(loadManifest)

  BRANCH_MANIFEST=$(echo "${MANIFEST}" | yq -r '.applications[].deployment[] | select(.branch == env.REPO_BRANCH)')
  [[ -z $BRANCH_MANIFEST ]] && BRANCH_MANIFEST=$(echo "${MANIFEST}" | yq -r '.applications[].deployment.default')

  echo $BRANCH_MANIFEST
}
export -f getBranchManifest

getAwsEnvBasedOnBranchName() {
  echo "$(getBranchManifest)" | jq -r '.awsenv // empty'
}
export -f getAwsEnvBasedOnBranchName

getAppEnvBasedOnBranchName() {
  echo "$(getBranchManifest)" | jq -r '.appenv // empty'
}
export -f getAppEnvBasedOnBranchName

getDomainBasedOnBranchName() {
  echo "$(getBranchManifest)" | jq -r '.domain // empty'
}
export -f getDomainBasedOnBranchName

getInternalDomainBasedOnBranchName() {
  echo "$(getBranchManifest)" | jq -r '.internaldomain // empty'
}
export -f getInternalDomainBasedOnBranchName

getPostfixBasedOnBranchName() {
  echo "$(getBranchManifest)" | jq -r '.postfix // empty'
}
export -f getPostfixBasedOnBranchName

# Required to be login to ECR
buildDockerImage() {
  IMAGE_NAME=$1
  IMAGE_TAG=$2

  if [[ -z ${IMAGE_NAME} ]]; then
    export IMAGE_NAME="${REPO_NAME}"
  fi

  if [[ -z ${IMAGE_TAG} ]]; then
    export IMAGE_TAG="${REPO_COMMIT_HASH:0:7}"
  fi

  # This need to provide some way of passing build-arg
  if [[ "${REPO_BRANCH}" = "master" ]]; then
    tlog INFO "Building a production docker image of ${IMAGE_NAME}:${IMAGE_TAG}..."
    docker build --build-arg environment=production -t "${IMAGE_NAME}:${IMAGE_TAG}" .
  else
    tlog INFO "Building a development docker image of ${IMAGE_NAME}:${IMAGE_TAG}..."
    docker build --build-arg environment=development -t "${IMAGE_NAME}:${IMAGE_TAG}" .
  fi

  tlog INFO "$(docker images)"
}
export -f buildDockerImage

uploadToEcr() {
  IMAGE_NAME=$1
  IMAGE_TAG=$2

  if [[ -z ${IMAGE_NAME} ]]; then
    export IMAGE_NAME="${REPO_NAME}"
  fi

  if [[ -z ${IMAGE_TAG} ]]; then
    export IMAGE_TAG="${REPO_COMMIT_HASH:0:7}"
  fi

  eval "$(aws ecr get-login --no-include-email)"

  tlog INFO "Creating ECR repo: ${IMAGE_NAME} if not exists..."
  aws ecr describe-repositories --repository-names ${IMAGE_NAME} || aws ecr create-repository --repository-name ${IMAGE_NAME}

  ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

  tlog INFO "Uploading the image ${IMAGE_NAME} and tags to ECR repo..."
  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}
  docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}

  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${REPO_BRANCH}-${PIPELINE_BUILD_NUM}
  docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${REPO_BRANCH}-${PIPELINE_BUILD_NUM}

  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${REPO_BRANCH}
  docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:${REPO_BRANCH}

  # Nothing should use latest tag
  #if [[ "${REPO_BRANCH}" = "master" ]]; then
  #  docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest
  #  docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_NAME}:latest
  #fi
}
export -f uploadToEcr

installAwsCli() {
  if [[ -z $(which aws) ]]; then
    export PATH=$HOME/bin:$PATH
    mkdir $HOME/bin
    #curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    #unzip awscli-bundle.zip
    #./awscli-bundle/install -b $HOME/bin/aws
    pip3 install --upgrade awscli
    #apk add jq
    curl -o $HOME/bin/jq -sSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
    chmod a+x $HOME/bin/jq
    tlog INFO "$(aws --version)"
    tlog INFO "$(jq --version)"
  fi  
}
export -f installAwsCli

uploadToEcrInTargetEnv() {
  AWSENV=$1
  IMAGE_NAME=$2
  IMAGE_TAG=$3

  if [[ -z $AWSENV ]]; then
    AWSENV=$(getAwsEnvBasedOnBranchName)  # parse ENV and DOMAIN from $DEPLOY's json
  fi

  if [[ -z $AWSENV ]]; then
    tlog ERROR "No target AWSENV designated."
    exit 1
  fi
  
  installAwsCli

  #runWithAwsCred -e $AWSENV -- uploadToEcr $IMAGE_NAME $IMAGE_TAG
  source <(getAwsCred $AWSENV)

  uploadToEcr $IMAGE_NAME $IMAGE_TAG  
}
export -f uploadToEcrInTargetEnv 

buildImageAndUploadToEcr() {
  AWSENV=$1
  IMAGE_NAME=$2
  IMAGE_TAG=$3

  buildDockerImage $IMAGE_NAME $IMAGE_TAG
  uploadToEcrInTargetEnv $AWSENV $IMAGE_NAME $IMAGE_TAG
}
export -f buildImageAndUploadToEcr

runWithAwsCred() {
  PARAMS=""
  while (( "$#" )); do
    case "$1" in
      -d|--do-not-assume-role)
        DO_NOT_ASSUME_ROLE=true
        shift
        ;;
      --) # end argument parsing
        EXEC_CMD=$@
        shift
        break
        ;;
      -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
      *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
  done
  # set positional arguments in their proper place
  eval set -- "$PARAMS"

  AWSENV=$1

  source <( getAwsCred ${AWSENV} )
  eval ${EXEC_CMD}
}
export -f runWithAwsCred

getAwsCred() {
  AWSENV=$1
  DO_NOT_ASSUME_ROLE=$2

  if [[ "${AWS_CRED_MODE}" = "SSM_CA_ROLES" ]]; then 
    getAwsCredFromSsm ${AWSENV} ${DO_NOT_ASSUME_ROLE}
  else
    getAwsCredFromEnvVars ${AWSENV} ${DO_NOT_ASSUME_ROLE}
  fi
}
export -f getAwsCred

getAwsCredFromEnvVars() {
  AWSENV=$1
  DO_NOT_ASSUME_ROLE=$2

  export AWS_ACCESS_KEY_ID=$(eval 'echo $'${AWSENV}_AWS_ACCESS_KEY)
  export AWS_SECRET_ACCESS_KEY=$(eval 'echo $'${AWSENV}_AWS_SECRET_KEY)
  export AWS_DEFAULT_REGION=$(eval 'echo $'${AWSENV}_AWS_DEFAULT_REGION)          # authenticate with the Docker Hub registry
  AWS_ASSUME_ROLE_ARN=$(eval 'echo $'${AWSENV}_AWS_ASSUME_ROLE_ARN)
  AWS_TFSTATE_S3_BUCKET=$(eval 'echo $'${AWSENV}_AWS_TFSTATE_S3_BUCKET)
  AWS_TFSTATE_S3_KEY=$(eval 'echo $'${AWSENV}_AWS_TFSTATE_S3_KEY)

  unset AWS_SESSION_TOKEN

  if [[ ( -z ${DO_NOT_ASSUME_ROLE} ) && ( ! -z ${AWS_ASSUME_ROLE_ARN} ) ]]; then
    CRED_JSON=$(aws sts assume-role --role-arn ${AWS_ASSUME_ROLE_ARN} --role-session-name s-${REPO_NAME}-${REPO_COMMIT_HASH:0:7} --duration 3600)
    AWS_ACCESS_KEY_ID=$(echo ${CRED_JSON} | jq -r '.Credentials.AccessKeyId')
    AWS_SECRET_ACCESS_KEY=$(echo ${CRED_JSON} | jq -r '.Credentials.SecretAccessKey')
    AWS_SESSION_TOKEN=$(echo ${CRED_JSON} | jq -r '.Credentials.SessionToken')
  fi

  echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
  echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
  echo "export AWS_ASSUME_ROLE_ARN=${AWS_ASSUME_ROLE_ARN}"
  echo "export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
  echo "export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}"
  echo "export AWS_TFSTATE_S3_BUCKET=${AWS_TFSTATE_S3_BUCKET}"
  echo "export AWS_TFSTATE_S3_KEY=${AWS_TFSTATE_S3_KEY}"
}
export -f getAwsCredFromEnvVars

getAwsCredFromSsm() {
  AWSENV=$1
  DO_NOT_ASSUME_ROLE=$2
  
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_ASSUME_ROLE_ARN
  unset AWS_DEFAULT_REGION
  unset AWS_SESSION_TOKEN
  unset AWS_TFSTATE_S3_BUCKET
  unset AWS_TFSTATE_S3_KEY

  #source <( getAwsCredFromEnvVars ${CI_AWSENV} true )
  source <( getAwsCredFromEnvVars ${AWSENV} true )
   
  source <( getSsmVars "" ${AWS_CRED_SSM_PATH}/${AWSENV} )

  if [[ ( -z ${DO_NOT_ASSUME_ROLE} ) && ( ! -z ${AWS_ASSUME_ROLE_ARN} ) ]]; then
    CRED_JSON=$(aws sts assume-role --role-arn ${AWS_ASSUME_ROLE_ARN} --role-session-name s-${REPO_NAME}-${REPO_COMMIT_HASH:0:7} --duration 3600)
    AWS_ACCESS_KEY_ID=$(echo ${CRED_JSON} | jq -r '.Credentials.AccessKeyId')
    AWS_SECRET_ACCESS_KEY=$(echo ${CRED_JSON} | jq -r '.Credentials.SecretAccessKey')
    AWS_SESSION_TOKEN=$(echo ${CRED_JSON} | jq -r '.Credentials.SessionToken')
  fi

  echo "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
  echo "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
  echo "export AWS_ASSUME_ROLE_ARN=${AWS_ASSUME_ROLE_ARN}"
  echo "export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
  echo "export AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}"
  echo "export AWS_TFSTATE_S3_BUCKET=${AWS_TFSTATE_S3_BUCKET}"
  echo "export AWS_TFSTATE_S3_KEY=${AWS_TFSTATE_S3_KEY}"
}
export -f getAwsCredFromSsm

runUtilityScriptFromBitbucketUri() {
  SCRIPT_URI=$1

  if [[ ! -z $SCRIPT_URI ]]; then
    shift
    SCRIPT_URL="${BITBUCKET_API}/${SCRIPTS_URI}"
    eval "curl -sSL ${SCRIPT_URL} | bash -s $@"
  fi
}
export -f runUtilityScriptFromBitbucketUri

createCommonTagsFile() {
  COMMON_TAGS=$1

  echo "locals {" > ${COMMON_TAGS}
  echo "  common_tags = {" >> ${COMMON_TAGS}

  # Add ENV vars starting with TF_VAR_ as TAGS without TF_VAR_
  OLD_IFS=$IFS
  IFS==; while read KEY VALUE; do
    if [[ ! -z ${VALUE} ]]; then 
      echo "${KEY//TF_VAR_/} = \"${VALUE//\'/}\"" >> ${COMMON_TAGS}
    fi
  done < <( ( set -o posix ; set ) | grep TF_VAR_ )
  IFS=$OLD_IFS
  
  echo "  }" >> ${COMMON_TAGS}
  echo "}" >> ${COMMON_TAGS}

  tlog DEBUG "$(cat ${COMMON_TAGS})"
}
export -f createCommonTagsFile

createProviderAwsTf() {
  PROVIDER_AWS=$1

  tlog INFO "Creating ${PROVIDER_AWS}..."

  cat <<EOF > ${PROVIDER_AWS}
    provider "aws" {
      access_key = "${AWS_ACCESS_KEY_ID}"
      secret_key = "${AWS_SECRET_ACCESS_KEY}"
      region = "${AWS_DEFAULT_REGION}"
      token = "${AWS_SESSION_TOKEN}"
      assume_role {
        role_arn = "${AWS_ASSUME_ROLE_ARN}"
      }
    }
EOF

  tlog DEBUG "$(cat ${PROVIDER_AWS})"
}
export -f createProviderAwsTf

createBackendS3Tf() {
  BACKEND_S3=$1

  cat <<EOF > ${BACKEND_S3}
    terraform {
      backend "s3" {
        access_key = "${AWS_ACCESS_KEY}"
        secret_key = "${AWS_SECRET_KEY}"
        region = "${AWS_DEFAULT_REGION}"
        token = "${AWS_SESSION_TOKEN}"
        role_arn = "${AWS_ASSUME_ROLE_ARN}"
        bucket = "${AWS_TFSTATE_S3_BUCKET}"
        key = "${AWS_TFSTATE_S3_KEY}"
      }
    }
EOF

  tlog DEBUG "$(cat ${BACKEND_S3})"
}
export -f createBackendS3Tf

doTerraform() {
  ACTION=$1
  APP_PREFIX=$2

  if [[ -z $APP_PREFIX ]]; then
    WORKSPACE_NAME=${REPO_NAME}-${REPO_BRANCH}
  else
    WORKSPACE_NAME=${REPO_NAME}-${REPO_BRANCH}-${APP_PREFIX}
  fi

  source <( getAwsCred ${AWSENV} )

  #### Create provider-aws.tf if any other provider* does not exists.
  if ls ./provider* 1> /dev/null 2>&1; then
    tlog INFO "Using $(ls -1 ./provider*) as provider"
  else
    createProviderAwsTf ./provider-aws.tf
  fi

  createCommonTagsFile ./common_tags.tf
  
  if ls ./backend* 1> /dev/null 2>&1; then
    tlog INFO "Using $(ls -1 ./backend*) as backend"
  else
    createBackendS3Tf ./backend-s3.tf
  fi

  terraform init -input=false     

  terraform workspace select ${WORKSPACE_NAME} || terraform workspace new ${WORKSPACE_NAME}

  terraform init -input=false -reconfigure      

  if [[ "${ACTION}" = "destroy" ]]; then
    terraform destroy -auto-approve -lock=true
    terraform workspace select default
    terraform workspace delete ${WORKSPACE_NAME}
  elif [[ "${ACTION}" = "plan" ]]; then
    terraform validate
    terraform plan -input=false -lock=true -lock-timeout=30s -out out.tfplan
  elif [[ "${ACTION}" = "apply" ]]; then
    terraform validate
    terraform plan -input=false -lock=true -lock-timeout=30s -out out.tfplan
    terraform apply -input=false -auto-approve -lock=true -lock-timeout=30s
  else
    tlog ERROR "/terraform \${ACTION} must be plan, apply, or destroy!"
    exit 1
  fi

  # This requires Git credential available t pipeline to have write access to the repo.
  if [[ -e ./workspace ]] &&  [[ -e ./backend-local.tf ]] && [[ ! -z "${REPO_BRANCH}" ]]; then
    git remote set-url origin ${REPO_URL}

    git config user.email "noreply@terraform.local"
    git config user.name "DevOps Team"
    git config push.default matching

    git add ./workspace
    git commit --message="workspace updated as the result of running: ${MESSAGE}"
    git push
  fi
}
export -f doTerraform

showTerraformOutput() {
  terraform output -no-color -json
}
export -f showTerraformOutput

deployEcs() {
  ACTION=$1
  TERRAFORM_DIR=$2
  APP_PREFIX=$3
  APP_IMAGE=$4
  APP_IMAGE_TAG=$5

  export AWSENV=$(getAwsEnvBasedOnBranchName)  # parse AWSENV and DOMAIN from $DEPLOY's json
  
  if [[ -z $AWSENV ]]; then
    tlog ERROR "No target AWSENV designated."
    exit 1
  fi

  export TF_VAR_AWSENV=${AWSENV}
  export TF_VAR_APPENV=$(getAppEnvBasedOnBranchName)

  export TF_VAR_DOMAIN=$(getDomainBasedOnBranchName)  # parse ENV and DOMAIN from $DEPLOY's json

  if [[ -z $APP_PREFIX ]]; then
    export TF_VAR_APP_PREFIX=$(getAppNameBasedOnRepoName)
  else
    export TF_VAR_APP_PREFIX=${APP_PREFIX}
  fi 

  export TF_VAR_APP_POSTFIX=$(eval echo $(getPostfixBasedOnBranchName))

  export TF_VAR_APP_UUID=${TF_VAR_APP_PREFIX}-${TF_VAR_APP_BRANCH_UUID}
  export TF_VAR_APP_FULLNAME=${TF_VAR_APP_PREFIX}${TF_VAR_APP_POSTFIX}

  export TF_VAR_FAMILY=$(getFamilyName)
  export TF_VAR_SSM_PATH=$(getSsmPath)

  if [[ -z $APP_IMAGE ]]; then
    export TF_VAR_APP_IMAGE=${REPO_NAME}
  else
    export TF_VAR_APP_IMAGE=${APP_IMAGE}
  fi

  if [[ -z $APP_IMAGE_TAG ]]; then
    export TF_VAR_APP_IMAGE_TAG=${REPO_COMMIT_HASH:0:7}
  else
    export TF_VAR_APP_IMAGE_TAG=${APP_IMAGE_TAG}
  fi

  tlog DEBUG "$(pwd)"
  tlog DEBUG "$(ls -l)"

  cd $TERRAFORM_DIR
  doTerraform $ACTION ${APP_PREFIX}
}
export -f deployEcs

addBuildStatus() {
  BUILD_NAME=$1

  if [[ ! -z ${BUILD_NAME} ]]; then
    eval curl -H "Content-Type: application/json" -X POST "${BUILD_URL}" -d "{ \"state\": \"SUCCESSFUL\", \"key\": \"${BUILD_NAME}\", \"name\": \"${BUILD_NAME}\", \"url\": \"${REPO_BUILD_NUM}\", \"description\": \"Passed ${BUILD_NAME}\" }"
  fi
}
export -f addBuildStatus

registerAppOnOkta() {
  APP_PREFIX=$(getAppNameBasedOnRepoName)
  APP_POSTFIX=$(eval echo $(getPostfixBasedOnBranchName))
  OKTA_APPNAME=$(getFamilyName)-${APP_PREFIX}-$(getAppEnvBasedOnBranchName)

  DOMAIN=$(getDomainBasedOnBranchName)
  TRUSTED_ORIGIN=$(echo https://${APP_PREFIX}${APP_POSTFIX}.${DOMAIN} | tr "[:upper:]" "[:lower:]")
  curl -s -L "${OKTA_CORS_REGISTER_SCRIPT}" | bash -x /dev/stdin ADD -t ${TRUSTED_ORIGIN} -n ${APP_PREFIX}${APP_POSTFIX}.${DOMAIN} -a ${OKTA_APPNAME} -r ${TRUSTED_ORIGIN}/implicit/callback
}
export -f registerAppOnOkta

copyImage() {
  FROM_AWSENV=$1
  TO_AWSENV=$2
  NEW_TAG=$3

  export FROM_IMAGE="${REPO_NAME}:${REPO_COMMIT_HASH:0:7}"

  if [[ -z $NEW_TAG ]]; then
    export TO_IMAGE="${REPO_NAME}:${REPO_COMMIT_HASH:0:7}"
  else
    export TO_IMAGE="${REPO_NAME}:${NEW_TAG}"
  fi

  installAwsCli

  source <(getAwsCred ${FROM_AWSENV})
  FROM_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
  eval "$(aws ecr get-login --no-include-email)"
  docker pull ${FROM_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${FROM_IMAGE}

  source <(getAwsCred ${TO_AWSENV})
  TO_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
  eval "$(aws ecr get-login --no-include-email)"

  aws ecr describe-repositories --repository-names ${TO_IMAGE%%:*} || aws ecr create-repository --repository-name ${TO_IMAGE%%:*}
  docker tag ${FROM_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${FROM_IMAGE} ${TO_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${TO_IMAGE}
  docker push ${TO_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${TO_IMAGE}
}
export -f copyImage

getSsmVars() {
  AWSENV=$1
  export SSM_PATH=$2

  if [[ ! -z ${AWSENV} ]]; then
    source <(getAwsCred ${AWSENV})
  fi

  while read KEY VALUE; do
      if [[ ( ! -z ${KEY} ) && ( ! $KEY == */* ) ]]; then
        echo "export ${KEY}=${VALUE}"
      fi
  done < <(aws ssm get-parameters-by-path --path /${SSM_PATH} | jq -r '.Parameters[] | .Name+" "+.Value | ltrimstr("/" + env.SSM_PATH + "/")')
}
export -f getSsmVars

getSsmVarsFromTargetEnv() {

  getSsmVars $(getAwsEnvBasedOnBranchName) $(getSsmPath)
}
export -f getSsmVarsFromTargetEnv

runTerraformByComment() {
  COMMIT_MESSAGE=${CI_COMMIT_TITLE}

  if [[ -z $AWSENV ]]; then
    if [[ ${REPO_BRANCH} == tf-* ]]; then
      REMINDER=${REPO_BRANCH#*-}  # remove "tf-"
      AWSENV=${REMINDER%%-*}
    else
      tlog INFO "nothing to do."
      exit 0
    fi
  fi

  function parseCommitMessage() {
    TERRAFORM=$1
    ACTION=$2
    TF_VARS=${@:3}
  }

  if [[ ! -z "${REPO_BRANCH}" ]]; then
    eval "parseCommitMessage ${COMMIT_MESSAGE}"
  fi

  if [[ ! "${TERRAFORM}" = "/terraform" ]]; then
    tlog INFO "The commit message does not start with /terraform.  Therefore it's just regular commit.  Nothing to do here."
    exit 0
  fi

  # Pass additional varaiable passed on the command to terraform
  for VAR in ${TF_VARS}; do
    eval "export TF_VAR_${VAR}"
  done

  doTerraform ${ACTION}
}
export -f runTerraformByComment

uploadScanResult() {
  SCAN_RESULT=$1

  source <(getSsmVarsFromTargetEnv)
  source <(getAwsCred $(getAwsEnvBasedOnBranchName))
  tlog DEBUG "$( ( set -o posix ; set ) | grep AWS_ )"

  aws s3 cp ${SCAN_RESULT} s3://${SCANRESULTSBUCKET}/${REPO_NAME}/${REPO_BRANCH}/${REPO_COMMIT_HASH:0:7}/${PIPELINE_BUILD_NUM}/${SCAN_RESULT}
}
export -f uploadScanResult

# Run Container Vulnerability Analysis Scan
runCvaScan() { 
  DOCKER_IMAGE=$1
  DOCKERFILE=$2
  SCAN_RESULT=${REPO_NAME}-${REPO_BRANCH}-${REPO_COMMIT_HASH:0:7}-${PIPELINE_BUILD_NUM}-cvascan.json
  
  snyk test --severity-threshold=low --docker ${DOCKER_IMAGE} --file=${DOCKERFILE} --json > ${SCAN_RESULT} || tlog INFO "Ignoring CVA vulnerability..."
  yqc r ${SCAN_RESULT}

  uploadScanResult ${SCAN_RESULT}

  if [[ "${UPLOAD_SCAN_RESULT}" = "true" ]]; then
    snyk monitor --severity-threshold=low --docker ${DOCKER_IMAGE} --file=${DOCKERFILE} --org=${REPO_WORKSPACE} --project-name=${REPO_NAME}-docker || tlog INFO "Ignoring CVA vulnerability..."
  fi
}
export -f runCvaScan

# Run Software Composition Analysis Scan
runScaScan() {
  APP_DIR=$1
  SCAN_RESULT=${REPO_NAME}-${REPO_BRANCH}-${REPO_COMMIT_HASH:0:7}-${PIPELINE_BUILD_NUM}-scascan.json
  
  cd ${APP_DIR}
  snyk test --severity-threshold=low --json > ${SCAN_RESULT} || tlog INFO "Ignoring SCA vulnerability..."
  yqc r ${SCAN_RESULT}

  uploadScanResult ${SCAN_RESULT}

  if [[ "${UPLOAD_SCAN_RESULT}" = "true" ]]; then
    snyk monitor --severity-threshold=low --org=${REPO_WORKSPACE} --project-name=${REPO_NAME} || tlog INFO "Ignoring SCA vulnerability..."
  fi
}
export -f runScaScan

runLocalSonarScanner() {
  APP_DIR=$1
  SCAN_RESULT=$2

  SONAR_LOGIN=admin
  SONAR_PASSWORD=admin
  SONAR_PORT=9000
  SONAR_URL=http://localhost:${SONAR_PORT}

  docker run -d --name sonarqube -p ${SONAR_PORT}:${SONAR_PORT} sonarqube:lts-alpine

  until [[ $(curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/system/status" | jq -r '.status') = "UP" ]]; do
      tlog INFO 'waiting for sonarqube server to start...'
      sleep 5
  done
  sleep 10

  sonar-scanner \
    -Dsonar.projectKey=${REPO_NAME} \
    -Dsonar.projectName=${REPO_NAME} \
    -Dsonar.projectVersion=${REPO_COMMIT_HASH:0:7} \
    -Dsonar.sources=${APP_DIR} \
    -Dsonar.login=${SONAR_LOGIN} \
    -Dsonar.password=${SONAR_PASSWORD} \
    -Dsonar.host.url=${SONAR_URL}

  until [[ $(curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/ce/component?component=${REPO_NAME}" | jq -r '.current.status') = "SUCCESS" ]]; do
      tlog INFO 'waiting for sonar scan to complete...'
      sleep 5
  done
  sleep 10

  curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/issues/search?componentKeys=${REPO_NAME}"  > ${SCAN_RESULT}
  yqc r ${SCAN_RESULT}
  docker stop sonarqube
  docker rm sonarqube

  # BELOW is Table format output
  # echo csv2table.py <EOF
  #   import pandas
  #   from tabulate import tabulate
  #   data = pandas.read_csv('./sonarscan-result.csv', index_col=0, sep=',')
  #   print(tabulate(data, headers=data.columns, tablefmt="grid"))
  #EOF
  #curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/issues/search?componentKeys=${REPO_NAME}" | sed -e 's/\\n//g' | jq -r '[.issues[] | { key, rule, severity, component, line, type, message }] | [.[] | with_entries( .key |= ascii_downcase ) ] | (.[0] |keys_unsorted | @csv), (.[]|.|map(.) |@csv)' > sonarscan-result.csv
  #wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'
  #python get-pip.py --disable-pip-version-check --no-cache-dir 
  #pip --version
  #pip install -q pandas tabulate
  #python ./sonarqube/csv2table.py
}
export -f runLocalSonarScanner

runSastScan() {
  APP_DIR=$1
  SCAN_RESULT=${REPO_NAME}-${REPO_BRANCH}-${REPO_COMMIT_HASH:0:7}-${PIPELINE_BUILD_NUM}-sastscan.json

  runLocalSonarScanner ${APP_DIR} ${SCAN_RESULT}

  uploadScanResult ${SCAN_RESULT}

  if [[ "${UPLOAD_SCAN_RESULT}" = "true" ]]; then
    sonar-scanner \
      -Dsonar.projectKey=${REPO_NAME} \
      -Dsonar.projectName=${REPO_NAME} \
      -Dsonar.projectVersion=${REPO_COMMIT_HASH:0:7} \
      -Dsonar.sources=${APP_DIR} \
      -Dsonar.organization=${REPO_WORKSPACE} \
      -Dsonar.host.url=https://sonarcloud.io
      #-Dsonar.tests=${APP_DIR} \
      #-Dsonar.test.inclusions="**/testing/**,**/*.spec.ts" \
      #-Dsonar.typescript.lcov.reportPaths=coverage/lcov.info \
      #-Dsonar.login=${SONARCLOUD_TOKEN} \     
  fi
}
export -f runSastScan

# Identify CI_TOOL and map the vars
if [[ ! -z "${BITBUCKET_REPO_SLUG}" ]]; then
  mapBitbucketPipelineVars
elif [[ ! -z "${GITLAB_CI}" ]]; then
  mapGitlabPipelineVars
else
  tlog ERROR "Can't identify what type of pipline tool is being used but won't stop you.  Good luck!"
  #exit 1
fi

export LOGGER_FMT=${LOGGER_FMT:="%Y-%m-%d %H:%M:%S"}
export LOGGER_LVL=${LOGGER_LVL:="INFO"}

tlog INFO "To change the log level, export LOGGER_LVL = ERROR | WARN | INFO | DEBUG"