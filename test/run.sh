#!/bin/bash
set -ex

for dir in "$@"; do
	image=$(echo $dir | sed -e "s/fpm/latest/")
	if ! docker inspect "$image" &> /dev/null; then
		echo "\timage does not exist!"
		exit 1
	fi
done
