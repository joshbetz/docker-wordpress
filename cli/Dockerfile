FROM joshbetz/wordpress

USER root
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		less \
		mariadb-client \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/wordpress

ENV WPCLI_VERSION 2.7.1
ENV WPCLI_SHA512 956b5e3e1a076bd5441c082ee754e3ff4517ec965b93c621f455c2bf5719358c36e67d52f676492700b59d42cacb34a50d382535c035f19da7a0b98bc41860de

# Install wp-cli
RUN set -ex; \
	curl -o /usr/local/bin/wp -SL https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar; \
	echo "$WPCLI_SHA512 /usr/local/bin/wp" | sha512sum -c -; \
	chmod +x /usr/local/bin/wp; \
	wp --allow-root --version

COPY wp-cli.yml /
ENV WP_CLI_CONFIG_PATH /wp-cli.yml

USER www-data
CMD ["wp", "shell"]
