# BIN KNOWLEDGE BASE

**Context:** Shell scripts for orchestrating the generation process.

## OVERVIEW
The entry points for the project. These scripts wrap the Docker execution of `openapi-generator-cli`.

## STRUCTURE
```
bin/
├── generate.sh                 # Main generic entry point
├── generate_*.sh               # Project-specific wrappers (Stripe, Google Drive)
└── common_generate.sh          # Shared Docker flags/setup
```

## KEY CONVENTIONS
- **Docker Wrapper**: All scripts MUST run the generator inside Docker to ensure consistency.
- **Mounts**: The project root is mounted to `/gen` inside the container.
- **Paths**: Arguments to `generate.sh` must be relative to the project root.
- **Clean Output**: Scripts should generally clean the output directory before generating to avoid stale files.

## USAGE
```bash
# Generic
./bin/generate.sh -i <spec> -o <out>

# Specific (encapsulates config)
./bin/generate_google_drive.sh
```

## ANTI-PATTERNS
- **Local Install**: Do not rely on a local `openapi-generator` binary. Always use the Docker image defined in the script.
- **Hardcoded Paths**: Avoid absolute paths; use `$(dirname "$0")` to locate the project root.
