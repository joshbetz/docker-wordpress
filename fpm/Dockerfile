FROM php:8.3-fpm

# install the PHP extensions we need
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		jq \
		libavif-dev \
		libfreetype6-dev \
		libicu-dev \
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
		--with-avif \
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
		apcu-5.1.24 \
		igbinary-3.2.16 \
		imagick-3.8.0 \
		memcache-8.2 \
		memcached-3.3.0 \
	; \
	docker-php-ext-enable \
		apcu \
		igbinary \
		imagick \
		memcache \
		memcached \
	; \
	# Remove development headers after building extensions to slim the image \
	apt-get purge -y \
		libavif-dev \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libmemcached-dev \
		libpng-dev \
		libssl-dev \
		libwebp-dev \
		libzip-dev \
		zlib1g-dev \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

ENV WORDPRESS_VERSION 6.8.3
ENV WORDPRESS_SHA1 fd56bcdc15f1877e45dce67942ea75949ed650e8

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
	&& chown -R www-data:www-data /var/www

USER www-data
WORKDIR /var/www

RUN composer init -n --name wordpress/wordpress \
       && composer config --no-plugins allow-plugins.composer/installers true

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
