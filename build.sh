#!/bin/bash
set -e
v=1.43.2
docker image build -t dastapov/hledger:latest-dev -t dastapov/hledger:${v}-dev --target dev . "$@"
docker image build -t dastapov/hledger:latest -t dastapov/hledger:${v} . "$@"

./run.sh ./data/hledger.journal hledger print || { echo "failed to run container, aborting"; exit 1; }

docker image push dastapov/hledger:${v}-dev
docker image push dastapov/hledger:latest-dev
docker image push dastapov/hledger:${v}
docker image push dastapov/hledger:latest
echo ./update_readme.sh
echo docker pushrm dastapov/hledger
