#!/bin/bash
set -ex

for image in "$@"; do
	if ! docker inspect "$image" &> /dev/null; then
		echo "\timage does not exist!"
		exit 1
	fi
done
