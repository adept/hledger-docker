#!/bin/bash
set -e -o pipefail
versions=$(mktemp)
trap 'rm -f "$versions"' EXIT
curl -L -s 'https://registry.hub.docker.com/v2/repositories/dastapov/hledger/tags?page_size=1024'|jq '."results"[]["name"]' | sed -e 's/"/`/g' > "$versions"
latest=$(head -n4 "$versions" | paste -s -d,)
rest=$(tail -n +5 "$versions" | paste -s -d,)
sed -i -e "s/Most recent:.*$/Most recent: $latest/" README.md
sed -i -e "s/Legacy:.*$/Legacy: $rest/" README.md
