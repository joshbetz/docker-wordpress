FROM php:7.3-fpm

# install the PHP extensions we need
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libmemcached-dev \
		zlib1g-dev \
	; \
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache; \
	pecl install memcached-3.0.4; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
COPY opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

ENV WORDPRESS_VERSION 5.0.1
ENV WORDPRESS_SHA1 298bd17feb7b4948e7eb8fa0cde17438a67db19a

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

# install wp-config.php
VOLUME /usr/src/wordpress
COPY ./wp-config.php /usr/src/wordpress

RUN mkdir -p /var/www/html/wp-content/plugins \
	&& mkdir -p /var/www/html/wp-content/themes \
	&& chown -R www-data:www-data /var/www/html
VOLUME /var/www/html
