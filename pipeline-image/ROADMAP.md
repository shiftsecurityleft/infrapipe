# End-To-End DevOps Pipeline

### Capabilities
1. Pluggability at each level
   * Deployment Target: AWS, Azure, GCD, CloudFlare
   * IaaS tools: Terraform , CloudFormation, CDK
   * Git repos: Github, Gitlab, Bitbucket
   * Test services:
   * Security services:
   * Log services:
   * Monitoring services:
2. Manage teams and permission at higher level
2. Manage environments
   Maps env name to AWS account, VPC, AWS Role to assume, git branch/tag name  
   * default: AWS-DEV, AWS-VPC, AWS-pipeline, any branch
3. Manage variables at org level and team level
3. Manage Workflow : Workflow connects multiple pipelines
2. Manage Git repo: 
   * create
   * update
   * delete
3. Update repo with sample: 
   * list and import sample from another repo
4. Manage CI pipeline
5. Manage development envronment:
   * Cloud 9
   * AWS Workspace
   * EC2
   * Jupyter Notebook
5. Manage Notification
5. Manage deployment
   * single deployment
   * Rolling deployment
   * Blue/Green deployment
   * Canary deployment
5. Manage Availability / DR
   * View/trigger auto-scale
   * View/Trigger az failover
   * View/Trigger region failover/recovery
   * View/Trigger DR failover/recovery
5. Manage jobs: scheduled or on-demand or event triggered
5. Manage modules: terraform module, internal app modules, pipeline action module 
6. Manage Artifacts: output of pipeline:
   * app packages
   * pipeline log
   * test log
   * security scan log
   * Docker image
5. Manage Dashboard
   * Org/Team view
   * Git status view
   * Test status view
   * List resources managed
   * Deployment view
   * Logging view
   * Artifacts view
   * Web User Request Analysis view
   * Performance view
   * Monitoring view
   * Security view
   * Availability Status view
   * Dependancies view
   * Issue view
   * Complieance view
