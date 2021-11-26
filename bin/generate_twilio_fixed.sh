#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

export shard_version=${shard_version:-1.23.6}
export spec_file_path='example_api_specs/twilio_api_v2010_1.23.1_fixed.json'
export out_dir='out/crystal/twilio_1.23.1_fixed_latest'
export additional_properties="shardName=twilio,moduleName=Twilio,shardLicense=MIT,shardVersion=$shard_version,shardAuthors=cyangle,shardDescription=Twilio API Client Generated by OpenAPI Generator"

$BASEDIR/generate_from_env.sh
