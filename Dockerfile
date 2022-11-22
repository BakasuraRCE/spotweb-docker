ARG BASE_IMAGE=litespeedtech/openlitespeed:1.7.16-lsphp81

FROM ${BASE_IMAGE} as build

ARG BRANCH

RUN apt-get update \
    && apt-get install -y \
    git

WORKDIR /app

RUN echo "Clone branch: ${BRANCH}" && git clone --branch ${BRANCH} https://github.com/spotweb/spotweb . && \
    # remove old deps
    rm -rf vendor composer.lock &&\
    # remove dev deps
    sed -i '/phpunit/d' composer.json &&\
    # install composer 2.x
    wget https://getcomposer.org/download/latest-stable/composer.phar -O composer.phar && \
    chmod +x composer.phar &&\
    # install latest deps
    ./composer.phar install --optimize-autoloader --no-dev &&\
    # install dotenv
    ./composer.phar require symfony/dotenv &&\
    ./composer.phar require szymach/c-pchart &&\
    # remove broken chart class
    rm -rf lib/services/Image/Services_Image_Chart.php

# replace chart class
COPY ./Services_Image_Chart.php lib/services/Image/Services_Image_Chart.php

FROM ${BASE_IMAGE}

RUN curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash &&\
    apt-get update &&\
    apt-get install -y \
    iputils-ping htop nano \
    # mysqladmin
    mariadb-client &&\
    rm -rf /var/lib/apt/lists/*

ENV APP_HOME /var/www/vhosts/localhost

WORKDIR ${APP_HOME}

# Setup PHP
RUN ln -sf /usr/local/lsws/lsphp81/bin/php /usr/bin/php && \
    ln -sf /usr/local/lsws/lsphp81/bin/pear /usr/bin/pear && \
    ln -sf /usr/local/lsws/lsphp81/bin/peardev /usr/bin/peardev && \
    ln -sf /usr/local/lsws/lsphp81/bin/pecl /usr/bin/pecl && \
    sed -i.bak -E 's/memory_limit.+?=.+/memory_limit = 1024M/' /usr/local/lsws/lsphp81/etc/php/8.1/litespeed/php.ini && \
    echo 'include_path = ".:/usr/local/lsws/lsphp81/share/php/"' >/usr/local/lsws/lsphp81/etc/php/8.1/mods-available/0-include-path.ini

# Create default PHP user
RUN groupadd worker &&\
    useradd -s /sbin/nologin -u 1000 -g worker -d ${APP_HOME} worker &&\
    # Let that OLS read static files
    usermod -g worker nobody &&\
    chown worker:worker -R ${APP_HOME}

COPY --chown=worker:worker ./entrypoint.sh /entrypoint.sh
COPY --chown=worker:worker ./cron.sh /cron.sh
COPY ./docker.conf /usr/local/lsws/conf/templates/docker.conf
COPY --chown=worker:worker ./bashrc ${APP_HOME}/.bashrc
COPY --chown=worker:worker ./dbsettings.inc.php ${APP_HOME}/dbsettings.inc.php
COPY --chown=worker:worker --from=build /app ${APP_FOLDER}


RUN chown worker:worker -R ${APP_HOME} &&\
    chown worker:worker -R /usr/local/lsws/ &&\
    chmod +x /cron.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]