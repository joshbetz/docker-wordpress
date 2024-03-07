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

ENV WPCLI_VERSION 2.10.0
ENV WPCLI_SHA512 c243265be520cd906f6dac767b56bb4e7dae9b6308db32b7e45ed8adbacad97bce987fd69b019d25478f394f0082404a0f44a93416f5e4d943cb32fd08f1feac

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
