ARG IMAGE_REF
FROM $IMAGE_REF/base
LABEL author="info@extremevalue.io"

#ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV NODE_VERSION=8.17.0 \
		NODE10_VERSION=10.21.0 \
    NVM_VERSION=0.35.3 \
		YARN_VERSION=1.22.4 \
		PYTHON_VERSION=3.8 \
		PYTHON_PIP_VERSION=19.2.3 \
		TF_VER=0.12.26 \
		SNYK_CLI_VER=v1.236.1 \
		YQC_VER=2.4.0 \
		SONARSCANNER_VER=3.4.0.1729-linux

ENV NVM_DIR=/root/.nvm \
		PATH=$NVM_DIR:$PATH


# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
		&& echo 'export NVM_DIR="/root/.nvm"' >> /root/.profile \
		&& echo '[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"' >> /root/.profile


# Set node path
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules

# Set the path.
ENV PATH=$NVM_DIR:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

##################################################################################
## Start of installation of tools
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
			ca-certificates \
			curl \
			netbase \
			wget \
			jq \
		&& rm -rf /var/lib/apt/lists/*

RUN set -ex; \
		if ! command -v gpg > /dev/null; then \
			apt-get update && apt-get install -y --no-install-recommends \
				gnupg \
				dirmngr \
			&& rm -rf /var/lib/apt/lists/*; \
		fi

RUN set -ex \
    && apt-get update && apt-get install -y \
			tk-dev \
			uuid-dev \
			zlib1g-dev 	\
			libncurses5-dev \
			libgdbm-dev 	\
			libnss3-dev 	\
			libssl-dev 	\
			libreadline-dev \
			libffi-dev 	\
    && rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D

# Install python3 and pip
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
			python${PYTHON_VERSION} \
			python3-pip \
		&& rm -rf /var/lib/apt/lists/*

# Install AWS cli.  JQ is preinstalled
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
		&& unzip awscliv2.zip \
		&& ./aws/install \
		&& rm -f awscliv2.zip \
		&& rm -rf aws

RUN python3 -m pip install --no-cache-dir docker-compose yq pipenv 

RUN pip install --no-cache-dir c7n

# Install terraform
RUN set -ex \
    && curl -o terraform.zip -sSL https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip \
    && unzip -o terraform.zip             \
    && mv terraform /usr/local/bin/       \
    && chmod a+x /usr/local/bin/terraform \
    && rm -f terraform.zip

# Install YARN.  NVM and NPM and Node are already installed
RUN set -ex \
    && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
    && mkdir -p /opt \
    && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
    && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
    && rm yarn-v$YARN_VERSION.tar.gz

# Install nvm with node and npm
RUN . $NVM_DIR/nvm.sh \
		&& nvm install $NODE10_VERSION \
		&& nvm install $NODE_VERSION \
		&& nvm use $NODE_VERSION

ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Snyk CLI
RUN set -ex \
    && curl -o /usr/local/bin/snyk -sSL https://github.com/snyk/snyk/releases/download/${SNYK_CLI_VER}/snyk-linux \
    && chmod a+x /usr/local/bin/snyk

# Install mikefarah yq and rename it yqc
RUN set -ex \
    && curl -o /usr/local/bin/yqc -sSL https://github.com/mikefarah/yq/releases/download/${YQC_VER}/yq_linux_amd64 \
    && chmod a+x /usr/local/bin/yqc

# Install sonarscanner
RUN set -ex \
    && curl -o sonar-scanner-cli.zip -sSL https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONARSCANNER_VER}.zip \
    && unzip -o sonar-scanner-cli.zip \
    && rm -f sonar-scanner-cli.zip \
		&& mv $(ls -1d sonar-scanner-*) /root/sonar-scanner
ENV PATH=/root/sonar-scanner/bin:$PATH

WORKDIR /opt/gitlab/cicd/agent/build

ENTRYPOINT /bin/bash
