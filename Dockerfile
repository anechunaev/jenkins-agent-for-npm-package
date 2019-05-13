FROM node:11-alpine

# NPM options
ARG NPM_TOKEN
ARG NPM_REGISTRY=https://registry.npmjs.org

# SonarQube options
ARG SONAR_TOKEN
ARG SONAR_HOST='http://localhost:9000'
ARG SONAR_CLI_VERSION='3.3.0.1492'
ARG SONAR_SCANNER_OPTS='-Xmx512m'

# Environment setup
# - NPM_CONFIG_USERCONFIG is pointing to the global npm config with authentification token.
# - NPM_CONFIG_CACHE is pointing to the directory with correct access rights for npm cache.
# - NO_UPDATE_NOTIFIER is for disabling notifications about new npm-cli versions.
ENV NPM_TOKEN=$NPM_TOKEN \
	NPM_REGISTRY=$NPM_REGISTRY \
	SONAR_TOKEN=$SONAR_TOKEN \
	SONAR_HOST=$SONAR_HOST \
	SONAR_SCANNER_OPTS=$SONAR_SCANNER_OPTS \
	SPAWN_WRAP_SHIM_ROOT=/tmp \
	NPM_CONFIG_USERCONFIG=/tmp/.npmrc \
	NPM_CONFIG_CACHE=/tmp/npmcache \
	NO_UPDATE_NOTIFIER=true \
	PATH="$PATH:/tmp/sonar/sonar-scanner-${SONAR_CLI_VERSION}-linux/bin"

# Dependencies setup
# - Install git because npm module might be defined with git url:
#   https://docs.npmjs.com/files/package.json#git-urls-as-dependencies
RUN apk add git unzip; \
	mkdir -p /tmp/npmcache && mkdir -p /tmp/sonar && chmod -R 777 /tmp/npmcache && chmod -R 777 /tmp/sonar; \
	wget -q -P /tmp/sonar https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_CLI_VERSION}-linux.zip \
	&& unzip -q /tmp/sonar/sonar-scanner-cli-${SONAR_CLI_VERSION}-linux.zip -d /tmp/sonar \
	&& printf "sonar.host.url=${SONAR_HOST}\nsonar.login=${SONAR_TOKEN}" >> /tmp/sonar/sonar-scanner-${SONAR_CLI_VERSION}-linux/conf/sonar-scanner.properties; \
	printf "registry=${NPM_REGISTRY}\n_authToken=${NPM_TOKEN}" >> ${NPM_CONFIG_USERCONFIG}
