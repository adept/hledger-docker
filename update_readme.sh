#!/bin/bash
curl -L -s 'https://registry.hub.docker.com/v2/repositories/dastapov/hledger/tags?page_size=1024'|jq '."results"[]["name"]' | sed -e 's/"/`/g' > /tmp/versions
latest=$(head -n4 /tmp/versions | paste -s -d,)
rest=$(tail -n +5 /tmp/versions | paste -s -d,)
sed -i -e "s/Most recent:.*$/Most recent: $latest/" README.md
sed -i -e "s/Legacy:.*$/Legacy: $rest/" README.md
