#/bin/sh

postman_file_path=$1

dir=$(dirname $0)
cd $dir

pwd

cat "$postman_file_path" | grep '"raw":' | egrep -o '\/v1[^\?^"]+' | sort | uniq > postman_stripe_api_endpoints.txt

ruby normalize_api_endpoints.rb postman_stripe_api_endpoints.txt > stripe_api_endpoints.txt
