FROM php:7.4-fpm

# install the PHP extensions we need
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libmemcached-dev \
		zlib1g-dev \
	; \
	docker-php-ext-configure gd --with-jpeg; \
	docker-php-ext-install gd mysqli opcache; \
	pecl install memcache-4.0.5.2; \
	docker-php-ext-enable memcache; \
	pecl install memcached-3.1.5; \
	docker-php-ext-enable memcached; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
COPY opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
COPY wordpress.ini /usr/local/etc/php/conf.d/wordpress.ini

ENV WORDPRESS_VERSION 5.8.3
ENV WORDPRESS_SHA1 3be7ed4dc6f46fe98271b974c88153640e95ad49

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

USER www-data

VOLUME /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
