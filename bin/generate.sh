#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

echo "Running in folder: ${PWD}"

docker run --rm -v "${PWD}:/gen" --workdir "/gen" openapitools/openapi-generator-cli generate \
    -g crystal \
    -c /gen/crystal_client_config.yml \
    "$@"
