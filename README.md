# crystal_client_generator
Custom OpenAPI Generator templates for generating crystal client libraries.

## What is OpenAPI Generator
[OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator) allows generation of API client libraries (SDK generation), server stubs, documentation and configuration automatically given an OpenAPI Spec (both 2.0 and 3.0 are supported).

OpenAPI Generator supports [User-defined Templates](https://github.com/OpenAPITools/openapi-generator/blob/master/docs/customization.md#user-defined-templates).

`crystal_client_generator` provides custom OpenAPI Generator templates for generating crystal client libraries.

## Usage

You need to have docker installed first with instructions from [here](https://docs.docker.com/get-docker/).

Run script `bin/generate.sh` from project root directory to generate the crystal client library.

`bin/generate.sh` runs OpenAPI Generator from inside a docker container, and mounts project root directory to `/gen` in the container, so you need to specify path arguments relative to project root.

You can place your OpenAPI specification file in folder `local/`, and generate the output to a subfolder in `out/`.

Files and folders under `local/` and `out/` are ignored by git.

Example command to generate google_drive library with api spec file `example_api_specs/google-drive-api-v3-oas3.json`.

```sh
./bin/generate.sh \
  -i example_api_specs/google-drive-api-v3-oas3.json \
  -o out/google_drive \
  --additional-properties=shardName=google_drive,moduleName=GoogleDrive,shardLicense=MIT,shardVersion=3.0.0,shardAuthors=cyangle,shardDescription=Google\ Drive\ V3\ API\ Client
```

The generated code would be written to `out/google_drive`.

## JSON (de)serialization

The generated code uses shard [nason](https://github.com/cyangle/nason) to (de)serialize from/to JSON.

The main difference between nason and standard library json is that it treats `null` value as of struct `Null` instead of `Nil`.

## SDKs generated with this repo

[Twilio](https://github.com/cyangle/twilio)

[Google Drive V3](https://github.com/cyangle/google_drive)

[Google Cloud Storage V1](https://github.com/cyangle/google_cloud_storage)
