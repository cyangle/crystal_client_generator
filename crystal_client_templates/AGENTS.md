# TEMPLATES KNOWLEDGE BASE

**Context:** Mustache templates for generating Crystal code.

## OVERVIEW
Contains the source logic for the generated Crystal shards. These templates are processed by OpenAPI Generator to produce the final `.cr` files.

## STRUCTURE
```
crystal_client_templates/
├── api.mustache            # API class logic (endpoints)
├── model.mustache          # Data models
├── shard.mustache          # shard.yml generation
├── configuration.mustache  # Client configuration
├── validators/             # Data validation logic (Enum, Primitive)
└── ext/                    # Extension helpers (Time, JSON)
```

## KEY CONVENTIONS
- **Namespace**: Always use `{{moduleName}}` for scoping.
- **HTTP Client**: Uses `Crest` for HTTP requests (defined in `api_client.mustache`).
- **Validation**:
  - `validators/` templates define runtime checks.
  - Failures raise `ArgumentError`.
- **Tests**:
  - `spec_helper.mustache` loads support files.
  - `vcr.cr` records HTTP interactions (sensitive headers masked).
  - **Stability Hack**: `ext.cr` hardcodes `MIME::Multipart` boundary to ensure deterministic VCR cassettes.


## CRITICAL RULES
- **Security**: `configuration.mustache` MUST default `verify_ssl` to `true`.
- **Headers**: HTTP header values must be comma-separated (`api_client.mustache`).
- **Compatibility**: Generated code targets Crystal >= 1.4.

## EDITING GUIDE
1. **Identify**: Find the target logic (e.g., "how models are defined" -> `model.mustache`).
2. **Edit**: Modify the `.mustache` file.
3. **Test**: Run `./bin/generate.sh` to produce output in `out/`.
4. **Verify**: Check the generated code in `out/` and run `crystal spec` *inside* the generated directory.
