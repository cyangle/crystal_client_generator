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
