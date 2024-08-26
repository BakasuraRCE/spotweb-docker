#!/bin/bash

source ~/.bashrc

cd /var/www/vhosts/localhost/ || exit

# Setup env file
env | grep '^SPOTWEB_' >.env
sed -i 's/SPOTWEB_//g' .env

# wait to mysql service
echo 'Waiting to mysql service'
while ! mariadb-admin ping -h"${SPOTWEB_MYSQL_HOST}" --silent; do
  sleep 1
done
echo 'mysql service up'


# Set PHP Timezone
echo "date.timezone = ${TZ}">/usr/local/lsws/lsphp81/etc/php/8.1/mods-available/0-timezone.ini

# Update db if needed(two times for first install)
php bin/upgrade-db.php >> /usr/local/lsws/logs/spotweb_upgrade_db.log 2>&1
php bin/upgrade-db.php >> /usr/local/lsws/logs/spotweb_upgrade_db.log 2>&1

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
