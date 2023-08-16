FROM php:8.2.9-fpm

# install the PHP extensions we need
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		jq \
		libjpeg-dev \
		libmagickwand-dev \
		libmemcached-dev \
		libpng-dev \
		libssl-dev \
		libzip-dev \
		unzip \
		zlib1g-dev \
	; \
	docker-php-ext-configure gd --with-jpeg; \
	docker-php-ext-install \
		exif \
		gd \
		intl \
		mysqli \
		opcache \
		zip \
	; \
	pecl install \
		apcu-5.1.22 \
		imagick-3.7.0 \
		memcache-8.0 \
		memcached-3.2.0 \
	; \
	docker-php-ext-enable \
		apcu \
		imagick \
		memcache \
		memcached \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

ENV WORDPRESS_VERSION 6.3
ENV WORDPRESS_SHA1 5ae2e02020004f7a848fc4015d309a0479f7c261

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

# install wp-config.php
COPY --chown=www-data:www-data ./wp-config.php /usr/src/wordpress

COPY install-* /usr/local/bin/

RUN mkdir -p /var/www/wp-content \
	&& mkdir /var/www/wp-content/plugins \
	&& mkdir /var/www/wp-content/themes \
	&& install-github-dropin automattic/wp-memcached object-cache.php \
	&& chown -R www-data:www-data /var/www/wp-content

USER www-data

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
