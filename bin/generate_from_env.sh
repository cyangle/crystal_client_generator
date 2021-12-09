#!/bin/sh

BASEDIR=$(dirname "$0")

cd "$BASEDIR/.."

echo "Running in folder: ${PWD}"

[ -z "${shard_version}" ] && echo "shard_version is not set" && exit 1
[ -z "${out_dir}" ] && echo "out_dir is not set" && exit 1
[ -z "${spec_file_path}" ] && echo "spec_file_path is not set" && exit 1
[ -z "${additional_properties}" ] && echo "additional_properties is not set" && exit 1
[ -z "${image}" ] && echo "image is not set" && exit 1

user=$(id -u)
repo_dir=${repo_dir:-$PWD}
echo "repo_dir is ${repo_dir}"

echo "shard version is ${shard_version}"

echo "Remove out_dir: $out_dir"
rm -rf $out_dir

echo "Generate code for spec file: $spec_file_path"
echo "Using image $image"
docker run --rm -v "${repo_dir}:/gen" --user "$user:$user" --workdir "/gen" $image generate \
    -g crystal \
    -c crystal_client_config.yml \
    -i $spec_file_path \
    -o $out_dir \
    --additional-properties="$additional_properties"

echo "Copy spec file to out_dir"
cp $spec_file_path $out_dir/
