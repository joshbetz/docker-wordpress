FROM joshbetz/wordpress

WORKDIR /usr/src/wordpress

# curl -iL https://github.com/wp-cli/wp-cli/releases/download/v1.5.0/wp-cli-1.5.0.phar.sha512
ENV WPCLI_VERSION 1.5.0
ENV WPCLI_SHA512 9385c63ab835c7c450529035cdb1f524b5878a67c7565c3497628e5ec4ec07ae4a34ef25c59a9e7d6edea7cdb039fcef7a1f731b922782b8c70418480bdff122

# Install wp-cli
RUN set -ex; \
	curl -o /usr/local/bin/wp -SL https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar; \
	echo "$WPCLI_SHA512 /usr/local/bin/wp" | sha512sum -c -; \
	chmod +x /usr/local/bin/wp; \
	wp --allow-root --version
