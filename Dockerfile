FROM node:12-alpine

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
	GIT_AUTHOR_NAME=$GIT_AUTHOR_NAME \
	GIT_AUTHOR_EMAIL=$GIT_AUTHOR_EMAIL \
	GIT_COMMITTER_NAME=$GIT_COMMITTER_NAME \
	GIT_COMMITTER_EMAIL=$GIT_COMMITTER_EMAIL \
	PATH="$PATH:/tmp/sonar/sonar-scanner-${SONAR_CLI_VERSION}-linux/bin"

# Dependencies setup
# - Install git because npm module might be defined with git url:
#   https://docs.npmjs.com/files/package.json#git-urls-as-dependencies
# - Install glibc for Alpine (sonar-scanner dependency of java)
#   https://github.com/bellingard/sonar-scanner-npm/issues/59
# - Install dependencies for Cypress
#   https://docs.cypress.io/guides/guides/continuous-integration.html#Advanced-setup
RUN apk update && apk add --no-cache git unzip ca-certificates wget openssh xvfb gtk+3.0 libnotify-dev gconf nss libxscrnsaver alsa-lib \
	&& printf "[user]\n\temail=${GIT_AUTHOR_EMAIL}\n\tname=${GIT_AUTHOR_NAME}" >> /.gitconfig; \
	mkdir -p /tmp/npmcache && mkdir -p /tmp/sonar && chmod -R 777 /tmp/npmcache && chmod -R 777 /tmp/sonar; \
	$( \
		wget -q -P /tmp/sonar https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_CLI_VERSION}-linux.zip \
		& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
		& wget -q -P /tmp https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \
	) \
	&& apk add /tmp/glibc-2.29-r0.apk \
	&& unzip -q /tmp/sonar/sonar-scanner-cli-${SONAR_CLI_VERSION}-linux.zip -d /tmp/sonar \
	&& printf "registry=\${NPM_REGISTRY}\n_authToken=\${NPM_TOKEN}" >> ${NPM_CONFIG_USERCONFIG}

CMD ["sh"]
