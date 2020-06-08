# Demo AWS S3 bucket Terraform

Include a sample Terraform which creates encrypted and private S3 bucket on AWS with logging enabled.

## Terraform versions

Only Terraform 0.12 is supported.

## Prerequsit
### 1. Install and enable pre-commit, awk, terraform-docs, tflint, git-chglog

```bash
brew install pre-commit awk terraform terraform-docs tflint git-chglog
```
### 2. Install the pre-commit hook globally

```bash
DIR=~/.git-template
git config --global init.templateDir ${DIR}
pre-commit init-templatedir -t pre-commit ${DIR}
```

### 3. Install semtag 

```bash
mkdir -p ~/bin
curl -o ~/bin/semtag -sSL https://raw.githubusercontent.com/pnikosis/semtag/master/semtag
chmod a+x ~/bin/semtag
echo "export PATH=$HOME/bin:$PATH" >> ~/.profile
```

## How to execute the Terraform

### 1. Create a tf-* branch

```bash
git checkout develop
git checkout -b tf-<ENV>-<DESCRIPTION>  # <ENV> = SNP1 | SP1 
```
### 2. Update main.tf or add *.tf.  No need to add AWS provider or backend or AWS credential.  These will be injected based on <ENV>.

### 3. Commit the changed files.  It might show failed when pre-commit auto-update the README.md based on the description fields of Terraform's variables and outputs.  Check the change and commit and push again.

```bash
git add .
git commit -m "commit message"
git push
```

### 4. Add blank-commit messgae as an Terraform action.  First plan, check the pipeline output then apply. 

```bash
git commit --allow-empty -m "/terraform {plan|apply|destroy} {<VAR>=<VALUE>}"; git push
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| TESTSEP | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| server\_ec2\_instance\_id | The EC2 instance ID |
| server\_ec2\_instance\_ip | The EC2 IP address |
| this\_centos\_ami | The centos AMI |
| this\_centos\_ami\_ids | The centos AMIs |
| this\_ssh\_keyname | The SSH keypair name |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [ShiftSecurityLeft](https://shiftsecurityleft.io).

## License

Apache 2 Licensed. See LICENSE for full details.
