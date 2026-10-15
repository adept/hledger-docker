#!/bin/bash
set -e
v=1.52.4
docker image build -t dastapov/hledger:latest-dev -t dastapov/hledger:${v}-dev --target dev . "$@"
docker image build -t dastapov/hledger:latest -t dastapov/hledger:${v} . "$@"

./smoke_test.sh dastapov/hledger:${v} || { echo "smoke test failed, aborting"; exit 1; }
docker image push dastapov/hledger:${v}-dev
docker image push dastapov/hledger:latest-dev
docker image push dastapov/hledger:${v}
docker image push dastapov/hledger:latest
echo ./update_readme.sh
echo docker pushrm dastapov/hledger
