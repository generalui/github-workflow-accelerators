# Tests

Unit tests for the shell scripts that power the GitHub Actions in this repository.

## Framework

Tests are written using [bats-core](https://github.com/bats-core/bats-core) — the Bash Automated Testing System.

## Structure

```text
tests/
├── unit/
│   ├── options_helpers.bats      # Tests for the shared options_helpers.sh utility
│   ├── aws_unset.bats            # Tests for the shared aws_unset.sh utility
│   ├── configure_pip.bats        # Tests for test-python/scripts/configure_pip.sh
│   ├── promote_image.bats        # Tests for promote-ecr-image/scripts/promote_image.sh
│   ├── update_ecs.bats           # Tests for update-aws-ecs/scripts/update_ecs.sh
│   └── update_lambda.bats        # Tests for update-aws-lambda/scripts/update_lambda.sh
└── helpers/
    └── mock_helpers.bash         # Shared mock creation and assertion utilities
```

## What Is Tested

| Script | Tests |
|--------|-------|
| `options_helpers.sh` | `has_argument()` and `extract_argument()` parsing logic |
| `aws_unset.sh` | All four AWS credential env vars are cleared |
| `configure_pip.sh` | Correct `pip config set` calls for each env var; no-op when unset |
| `promote_image.sh` | Env var validation (exits 1 for each missing required var) |
| `update_ecs.sh` | AWS CLI invocation, `--force-new-deployment`, empty-response failure |
| `update_lambda.sh` | AWS CLI invocation, function name + image URL propagation, failure |

### What Is NOT Tested Here

- **Composite action YAML** — action `.yml` files use GitHub Actions expression syntax
  (`${{ inputs.xxx }}`) that cannot run outside of a GitHub Actions runner.
- **Live AWS calls** — tests that require actual AWS credentials are integration tests
  and must run in a real CI environment with OIDC or stored secrets.

## Running Locally

### Install bats

```bash
# via npm (recommended)
npm install -g bats

# via Homebrew
brew install bats-core
```

### Run all tests

```bash
# From the repo root
bats tests/unit/
```

### Run a single test file

```bash
bats tests/unit/options_helpers.bats
```

### Run tests with verbose output

```bash
bats --verbose-run tests/unit/
```

## Writing New Tests

1. Create `tests/unit/<script_name>.bats`
2. Set `REPO_ROOT` using `BATS_TEST_DIRNAME` so paths are always absolute
3. Mock external commands (aws, docker, pip) using `MOCK_DIR` in PATH
4. Use `run bash -c "..."` for tests that expect `exit 1` from the script under test

See existing test files and `tests/helpers/mock_helpers.bash` for patterns.
