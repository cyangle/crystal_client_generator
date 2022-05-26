# 0.3.0

## improvements

Replace nason with json with ignore_serialize annotation to dynamically emit nulls based on #{name}_present?

# 0.2.2

## Bug fixes

Fix query_params in api to include Array(String)

# 0.2.1

## Bug fixes and improvements

Update crest to 1.1.0 and use Crest::NestedParamsEncoder by default

Remove generatorVersion from api_info.mustache

Refactor script generate_from_env.sh to run in container

Upgrade nason to 0.3.3

Add google cloud storage api spec and helper scripts

Upgrade post_process to v0.2.1

Refactor passing blocks

Refactor build_collection_param and build_api_request

Require extension files

Make image a shell variable in helper scripts

Fix EnumAttributeValidator

Fix form_params in api template

Set form_params to nil when it's not required

Add shard post_process to dev dependencies

Fix param description in api template

Refactor helper scripts

Update google drive spec

Add helper scripts to generate twilio and google drive clients

Explicitly (de)serialize date, datetime values

Fix more issues with twilio spec file

# 0.2.0

## Several bug fixes and refactors

Fix date and datetime (de)serialization

Fix twilio spec issue with incorrect type for price

Add google drive file update endpoints

Refactor present? in api.mustache

Refactor api client by removing unused return_type

Fix twilio OAS spec for map models

Refactor ApiClient#call_api

Break call_api into build_api_request and execute_api_request
Extract shared part of API methods into build_{{operationId}}_request

Add line break between SDK links in readme

Update readme with SDKs generated with this repo

Update readme template to include link to template repo

Refactor twilio model names and make page uris nullable

update twilio api spec to 1.23.1, also added the fixed version of it

Fix template issues with twilio api spec

Add twilio api spec

# 0.1.0

Basic working implementation. It could generate a working google drive v3 crystal client with spec file `example_api_specs/google-drive-api-v3-oas3.json`.
