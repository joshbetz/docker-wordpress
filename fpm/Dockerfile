FROM php:8.2.9-fpm

# install the PHP extensions we need
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		jq \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libmemcached-dev \
		libpng-dev \
		libssl-dev \
		libwebp-dev \
		libzip-dev \
		unzip \
		zlib1g-dev \
	; \
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	; \
	docker-php-ext-install -j $(nproc) \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		opcache \
		zip \
	; \
	pecl install \
		apcu-5.1.22 \
		igbinary-3.2.14 \
		imagick-3.7.0 \
		memcache-8.0 \
		memcached-3.2.0 \
	; \
	docker-php-ext-enable \
		apcu \
		igbinary \
		imagick \
		memcache \
		memcached \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

ENV WORDPRESS_VERSION 6.3.1
ENV WORDPRESS_SHA1 052777aef40e7f627c63c8a26eefe37b843a44df

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
