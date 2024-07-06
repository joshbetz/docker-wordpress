#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which jq > /dev/null || ( echo "Error: jq is required" && exit 1 )

PHP_VERSION="$(curl -s 'https://www.php.net/releases/?json&version=8.2' | jq -r .version)"
WORDPRESS_VERSION="$(curl -fsSL 'https://api.wordpress.org/core/version-check/1.7/' | jq -r '.offers[0].current')"
WPCLI_VERSION="$(curl -fsSL https://api.github.com/repos/wp-cli/wp-cli/releases/latest | jq -r '.tag_name' | sed -e 's/^v//g' )"

$DIR/update.sh "$PHP_VERSION" "$WORDPRESS_VERSION" "$WPCLI_VERSION" push

git commit $DIR/fpm -m "WordPress $WORDPRESS_VERSION"

git commit $DIR/cli -m "WP-CLI $WPCLI_VERSION"

git push
