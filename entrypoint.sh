#!/bin/bash

# Set PHP Timezone
echo "date.timezone = ${TZ}">/usr/local/lsws/lsphp74/etc/php/7.4/mods-available/0-timezone.ini

if [ -z "$(ls -A -- "/usr/local/lsws/conf/")" ]; then
	cp -R /usr/local/lsws/.conf/* /usr/local/lsws/conf/
	# Set PHP Timezone
	sed -i.bak '/phpIniOverride/,/\}/ s/\}/  php_admin_value date.timezone "'"${TZ/\//\\/}"'"\n}/' /usr/local/lsws/conf/templates/docker.conf
fi
if [ -z "$(ls -A -- "/usr/local/lsws/admin/conf/")" ]; then
	cp -R /usr/local/lsws/admin/.conf/* /usr/local/lsws/admin/conf/
fi
if [ -z "$(ls -A -- "/var/www/vhosts/localhost/")" ]; then
	mkdir -p /var/www/vhosts/localhost/
	cd /var/www/vhosts/localhost/

	git clone https://github.com/spotweb/spotweb .

	# Composer 1.x
	wget https://getcomposer.org/composer-1.phar -O composer.phar
	chmod +x composer.phar

	# Fix permissions
	cd /var/www && shopt -s dotglob && chown vhost:vhost . -R 
fi
chown 999:999 /usr/local/lsws/conf -R
chown 999:1000 /usr/local/lsws/admin/conf -R

# Touch crons
touch /etc/crontab /etc/cron.*/*
# Start cron
service cron start
# Start OLS
/usr/local/lsws/bin/lswsctrl start
$@
while true; do
	if ! /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done
