#!/bin/bash
set -ex
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which jq > /dev/null || ( echo "Error: jq is required" && exit 1 )

###
# WordPress Dockerfile
###
WORDPRESS_VERSION="$(curl -fsSL 'https://api.wordpress.org/core/version-check/1.7/' | jq -r '.offers[0].current')"
WORDPRESS_SHA1="$(curl -fsSL "https://wordpress.org/wordpress-$WORDPRESS_VERSION.tar.gz.sha1")"

sed \
	-e "s/%%WORDPRESS_VERSION%%/${WORDPRESS_VERSION}/g" \
	-e "s/%%WORDPRESS_SHA1%%/${WORDPRESS_SHA1}/g" \
	$DIR/Dockerfile-fpm.template > $DIR/fpm/Dockerfile

# Build new image if there are changes
if true || ! git diff --quiet --exit-code $DIR/fpm; then
	git diff $DIR/fpm/Dockerfile

	docker build -t joshbetz/wordpress -t joshbetz/wordpress:$WORDPRESS_VERSION $DIR/fpm
	docker push joshbetz/wordpress
	docker push joshbetz/wordpress:$WORDPRESS_VERSION
fi

###
# WP-CLI Dockerfile
###
WPCLI_VERSION="$(curl -fsSL https://api.github.com/repos/wp-cli/wp-cli/releases/latest | jq -r '.tag_name' | sed -e 's/^v//g' )"
WPCLI_SHA512="$(curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar.sha512")"

sed \
	-e "s/%%WPCLI_VERSION%%/${WPCLI_VERSION}/g" \
	-e "s/%%WPCLI_SHA512%%/${WPCLI_SHA512}/g" \
	$DIR/Dockerfile-cli.template > $DIR/cli/Dockerfile

# Build new image if there are changes in CLI or fpm (which are inherited by CLI)
if ! git diff --quiet --exit-code $DIR/cli || ! git diff --quiet --exit-code $DIR/fpm; then
	git diff $DIR/cli/Dockerfile

	docker build -t joshbetz/wordpress:cli -t joshbetz/wordpress:cli-$WPCLI_VERSION $DIR/cli
	docker push joshbetz/wordpress:cli
	docker push joshbetz/wordpress:cli-$WPCLI_VERSION
fi
