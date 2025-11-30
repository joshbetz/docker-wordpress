#!/bin/bash
#
# Builds and optionally pushes Docker images for WordPress and WP-CLI.
#
# Usage: ./build.sh [push]
#
# Options:
#   push    Push images to Docker Hub after building
#

set -eo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
action=$1

# Extract versions from Dockerfiles
WORDPRESS_VERSION=$(grep -oP 'ENV WORDPRESS_VERSION \K.*' $DIR/fpm/Dockerfile)
WPCLI_VERSION=$(grep -oP 'ENV WPCLI_VERSION \K.*' $DIR/cli/Dockerfile)

if [ -z "$WORDPRESS_VERSION" ]; then
	echo "Error: Could not extract WordPress version from fpm/Dockerfile"
	exit 1
fi

if [ -z "$WPCLI_VERSION" ]; then
	echo "Error: Could not extract WP-CLI version from cli/Dockerfile"
	exit 1
fi

echo "WordPress Version: $WORDPRESS_VERSION"
echo "WP-CLI Version: $WPCLI_VERSION"

# Create buildx builder if it doesn't exist
docker buildx create --name wordpress --use --bootstrap 2>/dev/null || docker buildx use wordpress

###
# Build WordPress FPM image
###
echo "Building WordPress FPM image..."
if [[ "push" == "$action" ]]; then
	docker buildx build --push \
		--platform linux/amd64,linux/arm64 \
		-t joshbetz/wordpress:latest \
		-t joshbetz/wordpress:$WORDPRESS_VERSION \
		$DIR/fpm
else
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t joshbetz/wordpress:latest \
		-t joshbetz/wordpress:$WORDPRESS_VERSION \
		$DIR/fpm
fi

###
# Build WP-CLI image
###
echo "Building WP-CLI image..."
if [[ "push" == "$action" ]]; then
	docker buildx build --push \
		--platform linux/amd64,linux/arm64 \
		-t joshbetz/wordpress:cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION \
		$DIR/cli
else
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		-t joshbetz/wordpress:cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION \
		$DIR/cli
fi

echo "Build complete."
