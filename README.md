# crystal_client_generator
Custom OpenAPI Generator templates for generating crystal client libraries.

## What is OpenAPI Generator
[OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator) allows generation of API client libraries (SDK generation), server stubs, documentation and configuration automatically given an OpenAPI Spec (only 3.0 is supported).

OpenAPI Generator supports [User-defined Templates](https://github.com/OpenAPITools/openapi-generator/blob/master/docs/customization.md#user-defined-templates).

`crystal_client_generator` provides custom OpenAPI Generator templates for generating crystal client libraries.

This readme is for version 0.3.3

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

## Advanced Usage

### Preprocess Steps

Sometimes the OpenAPI spec file needs to be cleaned up or modified before generation.

For example, you might want to normalize endpoint names, fix missing schema definitions, or group operations.

You can find examples of preprocessing scripts in `example_api_specs/`.

See `example_api_specs/fix_stripe.rb` for a complex example that handles schema grouping and fixes.

#### Recommended Normalization Tools

Writing custom scripts can be tedious. Consider using these specialized tools to normalize and deduplicate OpenAPI specs:

*   **[Redocly CLI](https://github.com/Redocly/redocly-cli)**: Industry standard (1.3k+ stars). To deduplicate inline schemas, use the **`split`** command (extracts inline schemas to components), followed by **`bundle`** (merges them back into a single normalized file).
*   **[openapi-format](https://github.com/thim81/openapi-format)**: Highly active tool (700+ stars) for sorting fields and filtering unused components. Essential for minimizing git diffs in generated code.
*   **[Vacuum](https://github.com/daveshanley/vacuum)**: The world's fastest OpenAPI linter (~1k stars). Use it to instantly validate massive specs like Stripe/Twilio and find inline schema violations.

> **Note**: I am not affiliated with any of the tools listed above.

### Postprocess Steps

The generated client includes a [`post_process`](https://github.com/cyangle/post_process) tool as a development dependency.

This tool allows you to automate find-and-replace tasks on the generated code using regex patterns.

1.  Create a `.post_process.yml` configuration file in your generated project root.
2.  Define tasks to modify files.

Example `.post_process.yml`:

```yaml
tasks:
  - name: "update api files"
    file_glob: './src/google_drive/api/*.cr'
    changes:
      -
        name: 'Remove common method prefix'
        pattern: 'drive_%{api_name}_'
        new_value: ''
```

Run the tool with:
```sh
./bin/post_process
```

For more details on `post_process`, see [post_process shard](https://github.com/cyangle/post_process).

For example post_process config files, see [google_drive_post_process_config](https://github.com/cyangle/google_drive/blob/dae0e1ad9e28fa46dd9477a2835c0f2fe2fe2dd3/.post_process.yml) and [stripe_post_process_config](https://github.com/cyangle/stripe/blob/e14533c9cab09909a749834bc14a18ad20fb5d47/.post_process.yml).

## SDKs generated with this repo

[Twilio](https://github.com/cyangle/twilio)

[Google Drive V3](https://github.com/cyangle/google_drive)

[Google Cloud Storage V1](https://github.com/cyangle/google_cloud_storage)
