#!/bin/bash
set -e -o pipefail

function usage() {
    echo "USAGE: $0 /path/to/hledger.journal [web|bash|hledger [hledger-args]]"
}

journal=$(readlink -f "$1") || { usage; exit 1; }
shift
dir=$(dirname "$journal")
file=$(basename "$journal")

cmd="$1"
shift

case "$cmd" in
    web) extra_args=""  ;;
    bash) extra_args="bash" ;;
    hledger) extra_args="hledger" ;;
    *)usage; exit 1 ;;
esac

docker container run --rm -it --volume "$dir:/data" \
       --env HLEDGER_JOURNAL_FILE=/data/$file \
       --env LEDGER_FILE=/data/$file \
       -p 5000:5000 \
       --user $(id --user) \
       dastapov/hledger $extra_args "$@"
