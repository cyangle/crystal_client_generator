#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

export shard_version=${shard_version:-0.0.1}
export image=${image:-'openapitools/openapi-generator-cli:latest'}
export spec_file_path='example_api_specs/stripe_api_spec_fixed.json'
export out_dir='/gen/stripe'
export additional_properties="generateFormAsModel=true,shardName=stripe,moduleName=Stripe,shardLicense=MIT,shardVersion=$shard_version,shardAuthors=cyangle,skipOperationExample=true,shardDescription=Stripe API Client Generated by OpenAPI Generator"
export skip_form_model=${skip_form_model:-"false"}

$BASEDIR/generate_from_env.sh
