FROM php:7.4

ARG PSR_VERSION=1.0.1
ARG PHALCON_VERSION=4.1.0
ARG PHALCON_EXT_PATH=php7/64bits
ARG DEV_TOOL_VERSION=4.0.3

# https://stackoverflow.com/questions/61815233/install-java-runtime-in-debian-based-docker-image
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2

# Add tooling -> need java for sonar qube agent
RUN set -e; \
    apt-get update; \
    apt-get upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends apt-utils build-essential wget make autoconf ssh bash vim git sqlite3 unzip default-jre;

# Install from PECL: Yaml Redis xdebug
RUN apt-get install -y libyaml-dev \
    && pecl install yaml \
    && pecl install redis \
    && pecl install psr \
    && pecl install xdebug-2.8.1 \
    && docker-php-ext-enable yaml redis xdebug psr

# Install Phalcon
RUN set -xe && \
        # Download PSR, see https://github.com/jbboehr/php-psr
        curl -LO https://github.com/jbboehr/php-psr/archive/v${PSR_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PSR_VERSION}.tar.gz && \
        # Compile Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} && \
        # Install dev tools
        curl -LOs https://github.com/phalcon/phalcon-devtools/releases/download/v${INSTALL_VERSION}/phalcon.phar && \
        chmod +x phalcon.phar && \
        mv phalcon.phar /usr/local/bin/phalcon && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION} \
            rm -rf v${PHALCON_VERSION}.tar.gz;

# install sonar cli
ENV SONAR_CLI_VERSION=4.5.0.2216
RUN set -e; \
    mkdir -p /opt/sonar; \
    mkdir -p /tmp/sonar-scanner; \
    curl -L -o /tmp/sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_CLI_VERSION}.zip; \
    unzip -o -d /tmp/sonar-scanner /tmp/sonar.zip; \
    mv /tmp/sonar-scanner/sonar-scanner-${SONAR_CLI_VERSION} /opt/sonar/scanner; \
    ln -s -f /opt/sonar/scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner; \
    rm -rf /tmp/sonar*


# Install php documentor
RUN cd /usr/local/bin && wget https://phpdoc.org/phpDocumentor.phar && chmod +x phpDocumentor.phar;

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /cms
