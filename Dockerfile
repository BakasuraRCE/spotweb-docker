FROM litespeedtech/openlitespeed:1.7.11-lsphp74
RUN apt-get update \
    && apt-get install -y \
    cron \
    git \
    && rm -rf /var/lib/apt/lists/*

# Setup PHP
RUN ln -sf /usr/local/lsws/lsphp74/bin/php /usr/bin/php && \
    ln -sf /usr/local/lsws/lsphp74/bin/pear /usr/bin/pear && \
    ln -sf /usr/local/lsws/lsphp74/bin/peardev /usr/bin/peardev && \
    ln -sf /usr/local/lsws/lsphp74/bin/pecl /usr/bin/pecl && \
    sed -i.bak -E 's/memory_limit.+?=.+/memory_limit = 1024M/' /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini && \
    echo 'include_path = ".:/usr/local/lsws/lsphp74/share/php/"' >/usr/local/lsws/lsphp74/etc/php/7.4/mods-available/0-include-path.ini

ADD entrypoint.sh /entrypoint.sh
ADD docker.conf /usr/local/lsws/.conf/templates/docker.conf
ADD htpasswd /usr/local/lsws/admin/.conf/htpasswd

# User for vhost directory
RUN useradd -M -u 2000 -d /var/www vhost

# Create crontab
RUN echo "*/5 * * * * vhost cd /var/www/vhosts/localhost && php retrieve.php >> /var/www/vhosts/localhost/cron.log 2>&1" >> /etc/crontab

RUN chown 999:999 /usr/local/lsws/conf -R
RUN cp -RP /usr/local/lsws/conf/ /usr/local/lsws/.conf/
RUN cp -RP /usr/local/lsws/admin/conf /usr/local/lsws/admin/.conf/
RUN rm -rf /var/www/vhosts/localhost

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]