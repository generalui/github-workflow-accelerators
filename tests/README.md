# Tests

Unit tests for the shell scripts that power the GitHub Actions in this repository.

## Framework

Tests are written using [bats-core](https://github.com/bats-core/bats-core) — the Bash Automated Testing System.

## Structure

Tests are organised per-action, mirroring the mono-repo structure of the actions themselves.
Each action that contains testable shell scripts has a corresponding directory under `tests/unit/`.

```text
tests/
├── unit/
│   ├── promote-ecr-image/
│   │   ├── test_aws_unset.bats        # Tests for the shared aws_unset.sh utility
│   │   ├── test_options_helpers.bats  # Tests for the shared options_helpers.sh utility
│   │   └── test_promote_image.bats    # Tests for promote_image.sh
│   ├── test-python/
│   │   └── test_configure_pip.bats    # Tests for configure_pip.sh
│   ├── update-aws-ecs/
│   │   └── test_update_ecs.bats       # Tests for update_ecs.sh
│   └── update-aws-lambda/
│       └── test_update_lambda.bats    # Tests for update_lambda.sh
└── helpers/
    └── mock_helpers.bash              # Shared mock creation and assertion utilities
```

## What Is Tested

| Action | Script | Tests |
| -------- | -------- | ------- |
| `promote-ecr-image` | `options_helpers.sh` | `has_argument()` and `extract_argument()` parsing logic |
| `promote-ecr-image` | `aws_unset.sh` | All four AWS credential env vars are cleared |
| `promote-ecr-image` | `promote_image.sh` | Env var validation (exits 1 for each missing required var) |
| `test-python` | `configure_pip.sh` | Correct `pip config set` calls for each env var; no-op when unset |
| `update-aws-ecs` | `update_ecs.sh` | AWS CLI invocation, `--force-new-deployment`, empty-response failure |
| `update-aws-lambda` | `update_lambda.sh` | AWS CLI invocation, function name + image URL propagation, failure |

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

### Run all tests for a specific action

```bash
# From the repo root
bats tests/unit/update-aws-ecs/
```

### Run tests for all actions

```bash
for dir in tests/unit/*/; do bats --verbose-run "$dir"; done
```

### Run with verbose output

```bash
bats --verbose-run tests/unit/promote-ecr-image/
```

## Writing New Tests

1. Create `tests/unit/<action-name>/test_<script_name>.bats`
2. Set `REPO_ROOT` relative to `BATS_TEST_DIRNAME` — tests are three levels deep,
   so use: `REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"`
3. Mock external commands (`aws`, `docker`, `pip`) using `MOCK_DIR` in PATH
4. Use `run bash -c "..."` for tests that expect `exit 1` from the script under test

See existing test files and `tests/helpers/mock_helpers.bash` for patterns.
