![Docker Pulls](https://img.shields.io/docker/pulls/bakasura/spotweb)
![Docker Stars](https://img.shields.io/docker/stars/bakasura/spotweb)

# Docker Spotweb image

An image running [openlitespeed/1.7.16-lsphp81](https://hub.docker.com/r/litespeedtech/openlitespeed) Linux and [Spotweb](https://github.com/spotweb/spotweb).

## Requirements

You need a separate MySQL / MariaDB server. This can of course be a (linked) docker container but also a dedicated database server.

If you would like to use docker-compose, a short guide can be found [below](#docker-compose).

## Usage

This is a **ROOTLESS** container, the default user ID is **1000**.

### Tags

| Tag       | Branch                                                             |
|-----------|--------------------------------------------------------------------|
| `latest`  | master([f1f122](https://github.com/spotweb/spotweb/tree/f1f122)).  |
| `develop` | develop([f6a02b](https://github.com/spotweb/spotweb/tree/f6a02b)). |

### Mount points

| Mount point                        | Function                                                               |
|------------------------------------|------------------------------------------------------------------------|
| `/var/www/vhosts/localhost/cache/` | Cache of spotweb.                                                      |
| `/usr/local/lsws/logs/`            | All logs from OLS, `Spotweb, Cron and Upgrade DB` will be placed here. |

### First install

There is some middleware here, first of all, we always run the
**bin/upgrade-db.php** in startup, this menas that the database will be populated for the first time.

Later, to set up the settings, you can provide the `SPOTWEB_INSTALL_KEY` to enable the **install.php** script, follow the steps:

1. Set `SPOTWEB_INSTALL_KEY` env variable with your secret random key
2. Deploy the docker compose and go to **/install.php?key=YOUR_INSTALL_KEY_HERE**
3. Enjoy your new installation without change your docker-compose file

### Environment variables

| Variable                 | Function                                |
|--------------------------|-----------------------------------------|
| `TIMEZONE`               | The timezone the server is running in.  |
| `SPOTWEB_INSTALL_KEY`    | The install key for first time install. |
| `SPOTWEB_DB_ENGINE`      | Just keep in pdo_mysql.                 |
| `SPOTWEB_MYSQL_HOST`     | The database hostname / IP.             |
| `SPOTWEB_MYSQL_DATABASE` | The database used for spotweb.          |
| `SPOTWEB_MYSQL_USER`     | The database server username.           |
| `SPOTWEB_MYSQL_PASSWORD` | The database server password.           |

### Updates

The container will try to auto-update the database when a newer version is released.

### Docker Compose

The best way to use this container is with a `docker-compose.yml` file, here is a basic example:

```
version: '3'
services:
  mysql:
    # check https://mariadb.org/mariadb/all-releases/
    image: mariadb:10.9
    command: [ 'mysqld', '--character-set-server=latin1', '--collation-server=latin1_swedish_ci', '--max_allowed_packet=1024M', '--innodb_file_per_table=1', '--innodb_buffer_pool_size=1G' ]
    user: "1000:1000"
    volumes:
      - ${MYSQL_FOLDER}:/var/lib/mysql:delegated
    environment:
      TZ: ${TIMEZONE}
      MARIADB_AUTO_UPGRADE: '1'
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    restart: always
  litespeed:
    image: bakasura/spotweb:latest
    user: "1000:1000"
    env_file:
      - .env
    volumes:
      - ${CACHE_FOLDER}:/var/www/vhosts/localhost/cache/
      - ${LOGS_FOLDER}:/usr/local/lsws/logs/
    ports:
      - "8980:80"
    restart: always
    depends_on:
      - mysql
    environment:
      TZ: ${TIMEZONE}
      SPOTWEB_INSTALL_KEY: ${SPOTWEB_INSTALL_KEY}
      SPOTWEB_DB_ENGINE: pdo_mysql
      SPOTWEB_MYSQL_HOST: mysql
      SPOTWEB_MYSQL_DATABASE: ${MYSQL_DATABASE}
      SPOTWEB_MYSQL_USER: ${MYSQL_USER}
      SPOTWEB_MYSQL_PASSWORD: ${MYSQL_PASSWORD}
  # Optinal
  phpmyadmin:
    image: bitnami/phpmyadmin:latest
    ports:
      - "8981:8080"
    depends_on:
      - mysql
    environment:
      DATABASE_HOST: mysql
    restart: always
```

## Repos

- [GitHub](https://github.com/BakasuraRCE/spotweb-docker)
- [Docker Hub](https://hub.docker.com/r/bakasura/spotweb)

## Author Information

[Bakasura](https://bakasurarce.github.io/)
