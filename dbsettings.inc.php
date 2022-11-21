<?php

use Symfony\Component\Dotenv\Dotenv;

$dotenv = new Dotenv();
$dotenv->load(__DIR__ . '/.env');

// Hack install.php to allow install with this file and ensure that need the install key
if ($_SERVER['SCRIPT_NAME'] === '/install.php') {
    session_start();

    if ($_GET['key']) {
        $_SESSION['install_key'] = $_GET['key'];
    }

    if (!$_ENV['INSTALL_KEY'] || $_SESSION['install_key'] !== $_ENV['INSTALL_KEY']) {
        exit(printf('Access denied'));
    }
} else {
    $dbsettings['engine'] = $_ENV['DB_ENGINE'];
    $dbsettings['host'] = $_ENV['MYSQL_HOST'];
    $dbsettings['dbname'] = $_ENV['MYSQL_DATABASE'];
    $dbsettings['user'] = $_ENV['MYSQL_USER'];
    $dbsettings['pass'] = $_ENV['MYSQL_PASSWORD'];
}