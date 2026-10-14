ARG WORDPRESS_BASE_IMAGE=wordpress:php8.2-apache
FROM ${WORDPRESS_BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl less mariadb-client \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && rm -rf /var/lib/apt/lists/*

COPY --chown=www-data:www-data theme/eazytraining-preprod/ /usr/src/wordpress/wp-content/themes/eazytraining-preprod/
COPY --chown=www-data:www-data plugin/give/ /usr/src/wordpress/wp-content/plugins/give/
