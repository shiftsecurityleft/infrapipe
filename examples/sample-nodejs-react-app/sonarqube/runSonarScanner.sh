#!/bin/bash
SONAR_LOGIN=admin
SONAR_PASSWORD=admin
SONAR_URL=http://localhost:9000
APP_SRC=$1

if [ "$(uname)" == "Darwin" ]; then
  curl -o "sonar-scanner-cli.zip" -sSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-macosx.zip
else
  curl -o "sonar-scanner-cli.zip" -sSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip
fi

unzip -q sonar-scanner-cli.zip && rm -f sonar-scanner-cli.zip
export PATH=$(ls -1d sonar-scanner-*)/bin:$PATH

#curl -o "$(ls -1d sonar-scanner-*)/bin/jq" -sSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
#chmod a+x $(ls -1d sonar-scanner-*)/bin/jq

until [[ $(curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/system/status" | jq -r '.status') = "UP" ]]; do
    echo 'waiting for sonarqube server to start...'
    sleep 5
done

sleep 10

sonar-scanner \
  -Dsonar.projectKey=${REPO_NAME} \
  -Dsonar.projectName=${REPO_NAME} \
  -Dsonar.projectVersion=${REPO_COMMIT_HASH:0:7} \
  -Dsonar.sources=${APP_SRC} \
  -Dsonar.login=${SONAR_LOGIN} \
  -Dsonar.password=${SONAR_PASSWORD} \
  -Dsonar.host.url=${SONAR_URL}

until [[ $(curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/ce/component?component=${REPO_NAME}" | jq -r '.current.status') = "SUCCESS" ]]; do
    echo 'waiting for sonar scan to complete...'
    sleep 5
done

sleep 10

curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/issues/search?componentKeys=${REPO_NAME}"  > ./sonar-scan.json
#curl -u ${SONAR_LOGIN}:${SONAR_PASSWORD} -sSL "${SONAR_URL}/api/issues/search?componentKeys=${REPO_NAME}" | sed -e 's/\\n//g' | jq -r '[.issues[] | { key, rule, severity, component, line, type, message }] | [.[] | with_entries( .key |= ascii_downcase ) ] | (.[0] |keys_unsorted | @csv), (.[]|.|map(.) |@csv)' > sonarscan-result.csv

#wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'
#python get-pip.py --disable-pip-version-check --no-cache-dir 
#pip --version

#pip install -q pandas tabulate
#python ./sonarqube/csv2table.py
curl -o "yq" -sSL "https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64"
chmod a+x yq
./yq r sonar-scan.json
