FROM litespeedtech/openlitespeed:1.7.16-lsphp74
RUN apt-get update \
    && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Setup PHP
RUN ln -sf /usr/local/lsws/lsphp74/bin/php /usr/bin/php && \
    ln -sf /usr/local/lsws/lsphp74/bin/pear /usr/bin/pear && \
    ln -sf /usr/local/lsws/lsphp74/bin/peardev /usr/bin/peardev && \
    ln -sf /usr/local/lsws/lsphp74/bin/pecl /usr/bin/pecl && \
    sed -i.bak -E 's/memory_limit.+?=.+/memory_limit = 1024M/' /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini && \
    echo 'include_path = ".:/usr/local/lsws/lsphp74/share/php/"' >/usr/local/lsws/lsphp74/etc/php/7.4/mods-available/0-include-path.ini

ENV APP_HOME /var/www/vhosts/localhost

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


# Create crontab
#RUN echo "*/5 * * * * worker cd ${APP_HOME} && php retrieve.php >> ${APP_HOME}/cron.log 2>&1" >> /etc/crontab

RUN chown worker:worker -R ${APP_HOME} &&\
    chown worker:worker -R /usr/local/lsws &&\
    chmod +x /cron.sh &&\
    chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]