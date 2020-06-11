ARG IMAGE_REF
FROM $IMAGE_REF/base
LABEL author="seongyong.kim@shiftsecurityleft.io"

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
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

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
		apt-get update; \
		apt-get install -y --no-install-recommends \
			gnupg \
			dirmngr \
		; \
		rm -rf /var/lib/apt/lists/*; \
	fi

RUN set -ex \
    && apt-get update \
    && apt-get install -y \
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

# RUN set -ex \
# 	\
# 	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
# 	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
# 	&& mkdir -p /usr/src/python \
# 	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
# 	&& rm python.tar.xz \
# 	\
# 	&& cd /usr/src/python \
# 	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
# 	&& ./configure \
# 		--build="$gnuArch" \
# 		--enable-loadable-sqlite-extensions \
# 		--enable-shared \
# 		--with-system-expat \
# 		--with-system-ffi \
# 		--without-ensurepip \
# 	&& make -j "$(nproc)" \
# 	&& make install \
# 	&& ldconfig \
# 	\
# 	&& find /usr/local -depth \
# 		\( \
# 			\( -type d -a \( -name test -o -name tests \) \) \
# 			-o \
# 			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
# 		\) -exec rm -rf '{}' + \
# 	&& rm -rf /usr/src/python \
# 	\
# 	&& python3 --version

# make some useful symlinks that are expected to exist
# RUN cd /usr/local/bin \
# 	&& ln -s idle3 idle \
# 	&& ln -s pydoc3 pydoc \
# 	&& ln -s python3 python \
# 	&& ln -s python3-config python-config

# RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

# RUN python3 get-pip.py

#RUN python3 -m pip3 install -U pip

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"

# RUN set -ex; \
# 	\
# 	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
# 	\
# 	python get-pip.py \
# 		--disable-pip-version-check \
# 		--no-cache-dir \
# 		"pip==$PYTHON_PIP_VERSION" \
# 	; \
# 	pip --version; \
# 	\
# 	find /usr/local -depth \
# 		\( \
# 			\( -type d -a \( -name test -o -name tests \) \) \
# 			-o \
# 			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
# 		\) -exec rm -rf '{}' +; \
# 	rm -f get-pip.py

# Install AWS cli.  JQ is preinstalled
RUN pip3 install --no-cache-dir awscli docker-compose yq pipenv

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
