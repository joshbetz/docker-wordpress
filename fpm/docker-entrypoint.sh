#!/bin/bash
set -e

file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"

	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi

	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi

	export "$var"="$val"
	unset "$fileVar"
}

# Load the MYSQL_PASSWORD from a secret file if it's defined
file_env "MYSQL_PASSWORD"

# If the first arg is an option, prepend php
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"
