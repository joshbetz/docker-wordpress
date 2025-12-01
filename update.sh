#!/bin/bash
#
# Generates Dockerfiles from templates using the latest upstream versions.
# If running in CI and changes are detected, commits and pushes the changes.
#
# Usage: ./update.sh
#

set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

which jq > /dev/null || ( echo "Error: jq is required" && exit 1 )

# Fetch latest versions with error handling
WORDPRESS_VERSION="$(curl -fsSL 'https://api.wordpress.org/core/version-check/1.7/' | jq -r '.offers[0].current')" || { echo "Error: Failed to fetch WordPress version"; exit 1; }
WPCLI_VERSION="$(curl -fsSL https://api.github.com/repos/wp-cli/wp-cli/releases/latest | jq -r '.tag_name' | sed -e 's/^v//g')" || { echo "Error: Failed to fetch WP-CLI version"; exit 1; }

if [ -z "$WORDPRESS_VERSION" ] || [ "$WORDPRESS_VERSION" == "null" ]; then
	echo "Error: Failed to fetch WordPress version"
	exit 1
fi

if [ -z "$WPCLI_VERSION" ] || [ "$WPCLI_VERSION" == "null" ]; then
	echo "Error: Failed to fetch WP-CLI version"
	exit 1
fi

echo "WordPress Version: $WORDPRESS_VERSION"
echo "WP-CLI Version: $WPCLI_VERSION"

###
# WordPress Dockerfile
###
WORDPRESS_SHA1="$(curl -fsSL "https://wordpress.org/wordpress-$WORDPRESS_VERSION.tar.gz.sha1")" || { echo "Error: Failed to fetch WordPress SHA1"; exit 1; }

if [ -z "$WORDPRESS_SHA1" ]; then
	echo "Error: Failed to fetch WordPress SHA1"
	exit 1
fi

sed \
	-e "s/%%WORDPRESS_VERSION%%/${WORDPRESS_VERSION}/g" \
	-e "s/%%WORDPRESS_SHA1%%/${WORDPRESS_SHA1}/g" \
	$DIR/Dockerfile-fpm.template > $DIR/fpm/Dockerfile

###
# WP-CLI Dockerfile
###
WPCLI_SHA512="$(curl -fsSL "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar.sha512")" || { echo "Error: Failed to fetch WP-CLI SHA512"; exit 1; }

if [ -z "$WPCLI_SHA512" ]; then
	echo "Error: Failed to fetch WP-CLI SHA512"
	exit 1
fi

sed \
	-e "s/%%WPCLI_VERSION%%/${WPCLI_VERSION}/g" \
	-e "s/%%WPCLI_SHA512%%/${WPCLI_SHA512}/g" \
	$DIR/Dockerfile-cli.template > $DIR/cli/Dockerfile

echo "Dockerfiles updated successfully."

# Check if there are changes
if git diff --quiet --exit-code $DIR/fpm $DIR/cli; then
	echo "No changes detected. Exiting."
	exit 0
fi

# Show changes
git diff $DIR/fpm/Dockerfile $DIR/cli/Dockerfile

# Commit changes (if running in CI)
if [ -n "$CI" ]; then
	# Configure git user for CI environment
	# Use environment variables if set, otherwise use defaults
	git config user.email "${GIT_USER_EMAIL:-j+bot@joshbetz.com}"
	git config user.name "${GIT_USER_NAME:-Josh Bot}"

	if ! git diff --quiet --exit-code $DIR/fpm; then
		git add $DIR/fpm
		git commit -m "WordPress $WORDPRESS_VERSION"
	fi

	if ! git diff --quiet --exit-code $DIR/cli; then
		git add $DIR/cli
		git commit -m "WP-CLI $WPCLI_VERSION"
	fi

	git push
fi
