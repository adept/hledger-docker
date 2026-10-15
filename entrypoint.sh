#!/bin/bash
# No arguments, or options only: start hledger-web with them (see start.sh).
# Anything else is a command to run, e.g. `hledger ...` or `bash`.
if [ $# -eq 0 ] || [ "${1#-}" != "$1" ]; then
    exec /start.sh "$@"
fi
exec "$@"
