# List of predefined variables
| InfraPipe variable      | Gitlab Variable | Description |
| :---        |    :----:   |          ---: |
| APP_BRANCH_UUID |  | first 7 chars of md5 hash of ${REPO_NAME}-${REPO_BRANCH} |
| AWS_CRED_MODE | 'SSM_CA_ROLES' |  |
| AWS_CRED_SSM_PATH | security/pipeline |  |
| CI_AWSENV | CI1 |  |
| CI_TOOL | GITLAB |  |
| MANIFEST_REPO | app-manifest |  |
| MANIFEST_VER | latest |  |
| PIPELINE_BUILD_DATETIME | $(date -Iseconds) |  |
| PIPELINE_BUILD_NUM | CI_PIPELINE_ID | The unique ID of the current pipeline that GitLab CI/CD uses internally |
| PIPELINE_BUILD_URL | CI_PIPELINE_URL | Pipeline details URL |
| REPO_BRANCH | CI_COMMIT_REF_NAME | The branch or tag name for which project is built |
| REPO_COMMIT_HASH | CI_COMMIT_SHA | The commit revision for which project is built |
| REPO_NAME | CI_PROJECT_NAME | "The name of the directory for the project that is currently being built. For example, if the project URL is gitlab.example.com/group-name/project-1, the CI_PROJECT_NAME would be project-1." |
| REPO_TAG | CI_COMMIT_TAG | The commit tag name. Present only when building tags. |
| REPO_URL | CI_PROJECT_URL | The HTTP(S) address to access project |
| REPO_WORKSPACE | CI_PROJECT_NAMESPACE | The project namespace (username or group name) that is currently being built |
| SCM_TOOL | GITLAB |  |

