#!/bin/bash

# Set PHP Timezone
echo "date.timezone = ${TZ}">/usr/local/lsws/lsphp74/etc/php/7.4/mods-available/0-timezone.ini

if [ -z "$(ls -A -- "/var/www/vhosts/localhost/")" ]; then
	mkdir -p /var/www/vhosts/localhost/
	cd /var/www/vhosts/localhost/

	git clone https://github.com/spotweb/spotweb .

	# Composer 1.x
	wget https://getcomposer.org/composer-1.phar -O composer.phar
	chmod +x composer.phar
fi

# Start rootless cron
/cron.sh &
# Start OLS
/usr/local/lsws/bin/lswsctrl start
$@
while true; do
	if ! /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done
