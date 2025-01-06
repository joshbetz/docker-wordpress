#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PHP_VERSION=$1
WORDPRESS_VERSION=$2
WPCLI_VERSION=$3
action=$4

if [ -z "$PHP_VERSION" ] || [ -z "$WORDPRESS_VERSION" ] || [ -z "$WPCLI_VERSION" ]; then
	echo "Usage: $0 <PHP_VERSION> <WORDPRESS_VERSION> <WPCLI_VERSION> [push]"
	exit 1
fi

which jq > /dev/null || ( echo "Error: jq is required" && exit 1 )

###
# WordPress Dockerfile
###
WORDPRESS_SHA1="$(curl -fsSL "https://wordpress.org/wordpress-$WORDPRESS_VERSION.tar.gz.sha1")"

sed \
	-e "s/%%PHP_VERSION%%/${PHP_VERSION}/g" \
	-e "s/%%WORDPRESS_VERSION%%/${WORDPRESS_VERSION}/g" \
	-e "s/%%WORDPRESS_SHA1%%/${WORDPRESS_SHA1}/g" \
	$DIR/Dockerfile-fpm.template > $DIR/fpm/Dockerfile

docker buildx create --name wordpress --use --bootstrap

# Build new image if there are changes
if ! git diff --quiet --exit-code $DIR/fpm; then
	git diff $DIR/fpm/Dockerfile

	if [[ "push" == "$action" ]]; then
		docker buildx build --push \
			--platform linux/amd64,linux/arm64 \
			-t joshbetz/wordpress -t joshbetz/wordpress:$WORDPRESS_VERSION $DIR/fpm
	else
		docker buildx build \
			--platform linux/amd64,linux/arm64 \
			-t joshbetz/wordpress -t joshbetz/wordpress:$WORDPRESS_VERSION $DIR/fpm
	fi
fi

###
# WP-CLI Dockerfile
###
WPCLI_SHA512="$(curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar.sha512")"

sed \
	-e "s/%%WPCLI_VERSION%%/${WPCLI_VERSION}/g" \
	-e "s/%%WPCLI_SHA512%%/${WPCLI_SHA512}/g" \
	$DIR/Dockerfile-cli.template > $DIR/cli/Dockerfile

# Build new image if there are changes in CLI or fpm (which are inherited by CLI)
if ! git diff --quiet --exit-code $DIR/cli || ! git diff --quiet --exit-code $DIR/fpm; then
	git diff $DIR/cli/Dockerfile

	if [[ "push" == "$action" ]]; then
		docker buildx build --push \
			--platform linux/amd64,linux/arm64 \
			-t joshbetz/wordpress:cli -t joshbetz/wordpress:$WORDPRESS_VERSION-cli -t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION $DIR/cli
	else
		docker buildx build \
			--platform linux/amd64,linux/arm64 \
			-t joshbetz/wordpress:cli -t joshbetz/wordpress:$WORDPRESS_VERSION-cli -t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION $DIR/cli
	fi
fi
