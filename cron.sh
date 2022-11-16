#!/bin/bash

cd /var/www/vhosts/localhost/

sleep 10
while true; do
	php -d memory_limit=1024M -d log_errors=on -d error_log=/var/www/vhosts/localhost/php.log -d error_reporting=32767 retrieve.php >> /var/www/vhosts/localhost/cron.log 2>&1
	sleep 60
done
