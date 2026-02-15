# EXAMPLE SPECS KNOWLEDGE BASE

**Context:** Input OpenAPI specifications and Ruby pre-processing scripts.

## OVERVIEW
Contains the input data for the generator (OpenAPI JSON/YAML) and the Ruby scripts used to clean, normalize, and fix these specs before generation.

## STRUCTURE
```
example_api_specs/
├── *.json / *.yaml         # Raw OpenAPI specifications
├── fix_*.rb                # Fix scripts (Stripe, Twilio specific)
├── normalize_*.rb          # General normalization logic
└── helpers.rb              # Shared utility functions
```

## WORKFLOW
1. **Raw Spec**: Place original spec in this directory.
2. **Analyze**: Check for inline schemas or missing definitions.
3. **Script**: Write/Update `fix_<name>.rb` to normalize the spec.
   - Use `extract_schema` to pull inline schemas to components.
   - Use `group_schema` to deduplicate similar models.
4. **Generate**: Point `bin/generate.sh` to the *fixed* spec, not the raw one.

## SCRIPTS
- **Language**: Ruby 3.1+
- **Dependencies**: `json`, `active_support`, `deepsort`
- **Goal**: Minimize git diffs in generated code by enforcing deterministic ordering and structure.

## ANTI-PATTERNS
- **Manual Edits**: Avoid manually editing large JSON specs. Use Ruby scripts to apply repeatable transformations.
- **Committing Raw Specs**: Only commit the *fixed* version if the raw one is too noisy/broken.
