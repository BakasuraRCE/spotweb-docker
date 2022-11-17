<?php

use Symfony\Component\Dotenv\Dotenv;

$dotenv = new Dotenv();
$dotenv->load(__DIR__ . '/.env');

$dbsettings['engine'] = 'mysql';
$dbsettings['host'] = $_ENV['MYSQL_HOST'];
$dbsettings['dbname'] = $_ENV['MYSQL_DATABASE'];
$dbsettings['user'] = $_ENV['MYSQL_USER'];
$dbsettings['pass'] = $_ENV['MYSQL_PASSWORD'];
