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

ENV WPCLI_VERSION 2.11.0
ENV WPCLI_SHA512 adb12146bab8d829621efed41124dcd0012f9027f47e0228be7080296167566070e4a026a09c3989907840b21de94b7a35f3bfbd5f827c12f27c5803546d1bba

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
