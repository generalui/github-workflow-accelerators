# Testing

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

| Action | Script | Tests | What's covered |
|--------|--------|-------|----------------|
| `promote-ecr-image` | `options_helpers.sh` | 15 | `has_argument()` and `extract_argument()` parsing logic |
| `promote-ecr-image` | `aws_unset.sh` | 7 | All 4 AWS credential env vars are cleared; no-op when already unset |
| `promote-ecr-image` | `promote_image.sh` | 13 | Every required env var validation (exits 1 for each missing var); `--help` |
| `test-python` | `configure_pip.sh` | 10 | Correct `pip config set` calls per env var; no-op when unset; `--help` |
| `update-aws-ecs` | `update_ecs.sh` | 8 | `--help`, `aws ecs update-service` invocation, `--force-new-deployment`, failure path |
| `update-aws-lambda` | `update_lambda.sh` | 7 | `--help`, `aws lambda update-function-code` invocation, failure path |

### What Is NOT Tested Here

- **Composite action YAML** — action `.yml` files use GitHub Actions expression syntax
  (`${{ inputs.xxx }}`) that cannot run outside of a GitHub Actions runner.
- **Live AWS calls** — tests that require actual AWS credentials are integration tests
  and must run in a real CI environment with OIDC or stored secrets.

## Mocking Strategy

External commands (`aws`, `pip`, `tput`) are replaced with lightweight mock binaries
that record every invocation to a log file (`$MOCK_DIR/<command>_calls.log`).
Tests assert the correct arguments were passed without hitting real cloud APIs.

`tests/helpers/mock_helpers.bash` provides shared utilities for creating mocks and
making assertions against them.

## Running Locally

### Install bats

```sh
# via npm (recommended — matches the CI install)
npm install -g bats

# via Homebrew
brew install bats-core
```

### Run all tests for a specific action

```sh
bats tests/unit/update-aws-ecs/
```

### Run tests for all actions

```sh
for dir in tests/unit/*/; do bats --verbose-run "$dir"; done
```

### Run with verbose output

```sh
bats --verbose-run tests/unit/promote-ecr-image/
```

## CI

The `code-quality.yml` workflow runs automatically on every PR to `main`.
It uses `tj-actions/changed-files` to detect which action directories have changed
and runs tests only for those actions — each in its own isolated job.

## Writing New Tests

For a full guide on writing new tests — including the mock pattern, exit code testing, and how to register
a new action with CI — see [WRITING_TESTS.md](./WRITING_TESTS.md).

Quick reference:

1. Create `tests/unit/<action-name>/test_<script_name>.bats`.
2. Set `REPO_ROOT` relative to `BATS_TEST_DIRNAME` — tests are three levels deep,
   so use: `REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"`
3. In `setup()`, create a `MOCK_DIR`, add mocks for any external commands, and prepend
   `$MOCK_DIR` to `PATH` — subshells spawned by `run bash -c "..."` inherit the PATH
   automatically, so do not re-export `PATH` inside the subshell.
4. Use `run bash -c "source '...script.sh'"` for tests that need to capture a non-zero
   exit code from the script under test.

See existing test files for patterns.
