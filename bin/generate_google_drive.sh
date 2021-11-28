#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

export shard_version=${shard_version:-3.1.2}
export image=${image:-'openapitools/openapi-generator-cli:latest'}
export spec_file_path='example_api_specs/google-drive-api-v3-oas3.json'
export out_dir='out/crystal/google_drive_latest'
export additional_properties="shardName=google_drive,moduleName=GoogleDrive,shardLicense=MIT,shardVersion=$shard_version,shardAuthors=cyangle,shardDescription=Google Drive V3 API Client Generated by OpenAPI Generator"

$BASEDIR/generate_from_env.sh
