#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

echo "Running in folder: ${PWD}"

rm -rf out/crystal/twilio_1.23.1_fixed_latest

docker run --rm -v "${PWD}:/gen" --workdir "/gen" openapitools/openapi-generator-cli:latest generate \
    -g crystal \
    -c crystal_client_config.yml \
    -i example_api_specs/twilio_api_v2010_1.23.1_fixed.json \
    -o out/crystal/twilio_1.23.1_fixed_latest \
    --additional-properties=shardName=twilio,moduleName=Twilio,shardLicense=MIT,shardVersion=1.23.6,shardAuthors=cyangle,shardDescription=Twilio\ API\ Client\ Generated\ by\ OpenAPI\ Generator
