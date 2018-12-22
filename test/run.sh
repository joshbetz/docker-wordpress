#!/bin/bash
set -ex
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for dir in "$@"; do
	case $dir in
		fpm)
			image="joshbetz/wordpress"
			;;
		*)
			image="joshbetz/wordpress:$dir"
			;;
	esac

	docker build $DIR/../$dir -t $image
	if ! docker inspect "$image" &> /dev/null; then
		echo "\timage does not exist!"
		exit 1
	fi
done
