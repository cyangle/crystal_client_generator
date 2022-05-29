#!/bin/sh

BASEDIR=$(dirname "$0")
cd "$BASEDIR/.."
echo "Running in folder: ${PWD}"

[ -z "${name}" ] && echo "name is not set" && exit 1
[ -z "${client_repo_path}" ] && echo "client_repo_path is not set" && exit 1
[ -z "${template_repo_path}" ] && echo "template_repo_path is not set" && exit 1
[ -z "${generate_script_path}" ] && echo "generate_script_path is not set" && exit 1
[ -z "${out_dir}" ] && echo "out_dir is not set" && exit 1
[ -z "${shard_version}" ] && echo "shard_version is not set" && exit 1

export shard_version
echo "Generate ${name} client"
$generate_script_path

echo "Update ${name} repo"
cp -Rf $out_dir/* $client_repo_path/
cp -Rf $out_dir/.openapi-generator $client_repo_path/

cd $client_repo_path
echo "Running in folder: ${PWD}"

echo "Post process code"
./bin/post_process
echo "Revert changes to README.md"
git checkout -- README.md
git checkout -- spec
echo "Run crystal tool format"
crystal tool format
echo "Install shards"
shards
echo "Run ameba"
./bin/ameba
