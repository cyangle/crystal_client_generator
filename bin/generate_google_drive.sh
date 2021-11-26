#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

echo "Running in folder: ${PWD}"

rm -rf out/crystal/google_drive_latest

docker run --rm -v "${PWD}:/gen" --workdir "/gen" openapitools/openapi-generator-cli:latest generate \
    -g crystal \
    -c crystal_client_config.yml \
    -i example_api_specs/google-drive-api-v3-oas3.json \
    -o out/crystal/google_drive_latest \
    --additional-properties=shardName=google_drive,moduleName=GoogleDrive,shardLicense=MIT,shardVersion=3.1.2,shardAuthors=cyangle,shardDescription=Google\ Drive\ V3\ API\ Client\ Generated\ by\ OpenAPI\ Generator
