#!/bin/bash

source ~/.bashrc

cd /var/www/vhosts/localhost/

sleep 10
while true; do
	php retrieve.php >> /usr/local/lsws/logs/spotweb_cron.log 2>&1
	sleep 60
done
