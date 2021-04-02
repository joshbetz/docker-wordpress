#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which jq > /dev/null || ( echo "Error: jq is required" && exit 1 )

$DIR/update.sh

WORDPRESS_VERSION="$(curl -fsSL 'https://api.wordpress.org/core/version-check/1.7/' | jq -r '.offers[0].current')"
git commit $DIR/fpm -m "WordPress $WORDPRESS_VERSION"

WPCLI_VERSION="$(curl -fsSL https://api.github.com/repos/wp-cli/wp-cli/releases/latest | jq -r '.tag_name' | sed -e 's/^v//g' )"
git commit $DIR/cli -m "WP-CLI $WPCLI_VERSION"

git push
