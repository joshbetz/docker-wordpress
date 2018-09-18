#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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
if [[ ! $(git diff --quiet --exit-code $DIR/fpm/Dockerfile) ]]; then
	git diff $DIR/fpm/Dockerfile

	docker build -t joshbetz/wordpress $DIR/fpm
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

# Build new image if there are changes
if [[ ! $(git diff --quiet --exit-code $DIR/cli/Dockerfile) ]]; then
	git diff $DIR/cli/Dockerfile

	docker build -t joshbetz/wordpress:cli $DIR/cli
fi
