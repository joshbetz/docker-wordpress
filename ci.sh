#!/bin/bash
#
# CI script that checks for updates, generates Dockerfiles, and builds/pushes images.
# This is the main entry point for the CI workflow.
#
# Usage: ./ci.sh [push]
#
# Options:
#   push    Push images to Docker Hub after building
#

set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
action=$1

# Update Dockerfiles from templates
$DIR/update.sh

# Check if there are changes
if git diff --quiet --exit-code $DIR/fpm $DIR/cli; then
	echo "No changes detected. Exiting."
	exit 0
fi

# Show changes
git diff $DIR/fpm/Dockerfile $DIR/cli/Dockerfile

# Build and optionally push
$DIR/build.sh $action

# Commit changes (if running in CI)
if [ -n "$CI" ]; then
	WORDPRESS_VERSION=$(grep 'ENV WORDPRESS_VERSION' $DIR/fpm/Dockerfile | sed 's/ENV WORDPRESS_VERSION //')
	WPCLI_VERSION=$(grep 'ENV WPCLI_VERSION' $DIR/cli/Dockerfile | sed 's/ENV WPCLI_VERSION //')

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
