#!/bin/bash
set -e
v=1.14
docker image pull haskell
docker image build -t dastapov/hledger:latest-dev -t dastapov/hledger:${v}-dev --target dev .
docker image build -t dastapov/hledger:latest -t dastapov/hledger:${v} .

docker image push dastapov/hledger:${v}-dev
docker image push dastapov/hledger:latest-dev
docker image push dastapov/hledger:${v}
docker image push dastapov/hledger:latest
