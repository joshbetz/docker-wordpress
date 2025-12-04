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

# Extract versions from Dockerfiles using portable grep/sed
WORDPRESS_VERSION=$(grep 'ENV WORDPRESS_VERSION' $DIR/fpm/Dockerfile | sed 's/ENV WORDPRESS_VERSION //')
WPCLI_VERSION=$(grep 'ENV WPCLI_VERSION' $DIR/cli/Dockerfile | sed 's/ENV WPCLI_VERSION //')

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
if ! docker buildx inspect wordpress > /dev/null 2>&1; then
	echo "Creating buildx builder 'wordpress'..."
	docker buildx create --name wordpress --use --bootstrap
else
	echo "Using existing buildx builder 'wordpress'..."
	docker buildx use wordpress
fi

###
# Build WordPress FPM image
###
echo "Building WordPress FPM image..."
if [[ "push" == "$action" ]]; then
	docker buildx build --push \
		--platform linux/amd64,linux/arm64 \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from type=registry,ref=joshbetz/wordpress:latest \
		-t joshbetz/wordpress:latest \
		-t joshbetz/wordpress:$WORDPRESS_VERSION \
		$DIR/fpm
else
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from type=registry,ref=joshbetz/wordpress:latest \
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
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from type=registry,ref=joshbetz/wordpress:cli \
		-t joshbetz/wordpress:cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION \
		$DIR/cli
else
	docker buildx build \
		--platform linux/amd64,linux/arm64 \
		--build-arg BUILDKIT_INLINE_CACHE=1 \
		--cache-from type=registry,ref=joshbetz/wordpress:cli \
		-t joshbetz/wordpress:cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli \
		-t joshbetz/wordpress:$WORDPRESS_VERSION-cli-$WPCLI_VERSION \
		$DIR/cli
fi

echo "Build complete."
