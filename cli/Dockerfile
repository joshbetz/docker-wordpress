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

ENV WPCLI_VERSION 2.2.0
ENV WPCLI_SHA512 2103f04a5014d629eaa42755815c9cec6bb489ed7b0ea6e77dedb309e8af098ab902b2f9c6369ae4b7cb8cc1f20fbb4dedcda83eb1d0c34b880fa6e8a3ae249d

# Install wp-cli
RUN set -ex; \
	curl -o /usr/local/bin/wp -SL https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar; \
	echo "$WPCLI_SHA512 /usr/local/bin/wp" | sha512sum -c -; \
	chmod +x /usr/local/bin/wp; \
	wp --allow-root --version

USER www-data
CMD ["wp", "shell"]
