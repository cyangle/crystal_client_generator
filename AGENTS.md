# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-15
**Type:** OpenAPI Generator Templates (Meta-Project)

## OVERVIEW
This project is a **Crystal Client Generator** for OpenAPI. It functions as a meta-project, using **Mustache templates** and **Shell scripts** to generate standard Crystal shards from OpenAPI specifications. It relies on the Dockerized `openapi-generator-cli`.

## STRUCTURE
```
.
├── bin/                        # Entry points (generation scripts)
├── crystal_client_templates/   # THE SOURCE: Mustache templates for Crystal code
├── example_api_specs/          # Input: OpenAPI specs + pre-processing scripts
├── crystal_client_config.yml   # Configuration mapping templates to files
├── local/                      # Local scratchpad (git-ignored)
└── out/                        # Generated Crystal Shards (git-ignored)
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| **Edit Logic** | `crystal_client_templates/` | Modify mustache files here, not in `out/` |
| **Run Generator** | `bin/generate.sh` | Main entry point |
| **Add Config** | `crystal_client_config.yml` | Map new templates to destinations |
| **Pre-process Specs** | `example_api_specs/` | Ruby scripts to fix/normalize JSON specs |

## CONVENTIONS
- **Meta-Project**: The root is NOT a Crystal shard. It has no `shard.yml`.
- **Docker-First**: Generation runs inside Docker. Paths in `bin/generate.sh` are mounted.
- **Verification**: Always enable SSL verification in production templates.
- **Specs**: Input OpenAPI specs should be **normalized** (no inline schemas) to avoid diff noise.
- **Testing Stability**: Generated tests use `VCR` for HTTP mocking. A hardcoded `MIME::Multipart` boundary is injected (`ext.cr`) to ensure cassette consistency.
- **Patching**: Manual fixes to generated code can be persisted via `.patch` files in a `patches/` directory, applied automatically by `bin/common_generate.sh`.

## ANTI-PATTERNS (THIS PROJECT)
- **Direct Edits**: NEVER edit files in `out/`. They are overwritten on regeneration.
- **Inline Schemas**: Do not use inline schemas in OpenAPI specs; extract to components.
- **Timeout=0**: Never set timeout to 0 (infinite) in templates.

## COMMANDS
```bash
# Generate a client (requires Docker)
./bin/generate.sh -i <spec_file> -o <output_dir> --additional-properties=...

# Example
./bin/generate.sh \
  -i example_api_specs/google-drive-api-v3-oas3.json \
  -o out/google_drive \
  --additional-properties=shardName=google_drive,moduleName=GoogleDrive
```
