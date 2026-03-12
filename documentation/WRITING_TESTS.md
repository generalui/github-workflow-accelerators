# Writing Tests

This guide covers how to write bats unit tests for shell scripts in this repository.
For running existing tests locally, see [TESTING.md](./TESTING.md).

## What to Test

Tests cover the **shell scripts** inside each action's `scripts/` directory. Composite action
`action.yml` files use GitHub Actions expression syntax (`${{ inputs.xxx }}`) that cannot run
outside a real runner and are therefore out of scope for unit tests.

Good candidates for testing:

- Input validation (does the script exit 1 when a required env var is missing?)
- Core logic (does the script call the right CLI with the right arguments?)
- Edge cases (what happens with empty strings, missing optional vars, `--help`?)

## File Location

Tests live in `tests/unit/{action-name}/`, one directory per action. Each test file is named `test_{script_name}.bats`.

```text
tests/
└── unit/
    └── update-aws-ecs/
        └── test_update_ecs.bats
```

## Anatomy of a Test File

```bash
#!/usr/bin/env bats
# Brief description of what this file tests.

# REPO_ROOT must use this exact depth — tests are 3 levels deep.
REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/.github/actions/my-action/scripts/my_script.sh"

setup() {
  # Create mock binaries, set env vars, etc.
}

teardown() {
  # Clean up temp files, unset env vars.
}

@test "my_script: does something expected" {
  # Arrange, act, assert
}
```

### Critical: `BATS_TEST_DIRNAME` Depth

Tests are located at `tests/unit/{action-name}/test_*.bats` — three directory levels below the repo root. Always use:

```bash
REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
```

## Mocking External Commands

External commands (`aws`, `pip`, `docker`, `tput`) must be mocked — tests must not make real network calls.

The standard pattern is to create lightweight mock executables in a temp directory and prepend it to `PATH`:

```bash
setup() {
  MOCK_DIR="$(mktemp -d)"
  export MOCK_DIR

  # Mock aws: records all calls to a log file
  cat > "$MOCK_DIR/aws" << MOCK
#!/bin/bash
echo "\$@" >> "${MOCK_DIR}/aws_calls.log"
exit 0
MOCK
  chmod +x "$MOCK_DIR/aws"

  # Prepend mock dir — subshells inherit this PATH automatically
  export PATH="$MOCK_DIR:$PATH"
}

teardown() {
  [ -n "${MOCK_DIR:-}" ] && rm -rf "$MOCK_DIR"
}
```

Then assert against the call log:

```bash
@test "script: calls aws ecs update-service" {
  bash -c "source '$SCRIPT_UNDER_TEST'"
  grep -q "update-service" "$MOCK_DIR/aws_calls.log"
}
```

**Do not re-export `PATH` inside `run bash -c "..."` subshells** — they inherit `PATH` from `setup()` automatically. Overriding it in the subshell can break system tools like `dirname`.

### Shared Helpers

`tests/helpers/mock_helpers.bash` provides `setup_mocks`, `assert_mock_called_with`, and `assert_mock_not_called` utilities. See the file for usage.

## Testing Exit Codes

To assert that a script exits with a non-zero code, use `run bash -c "..."`:

```bash
@test "script: exits 1 when required var is missing" {
  run bash -c "source '$SCRIPT_UNDER_TEST'"
  [ "$status" -eq 1 ]
}
```

`run` captures the exit code in `$status` and stdout/stderr in `$output`. Without `run`, a non-zero exit would cause the test itself to fail before you can assert.

## Adding Tests for a New Action

1. Create the directory: `tests/unit/{action-name}/`
2. Create `tests/unit/{action-name}/test_{script_name}.bats`
3. Register the action in `.github/workflows/code-quality.yml`:

   ```yaml
   actions_with_tests=(
     "my-new-action"
     ...
   )
   ```

   Without this, CI will not run your tests on PRs.

## Running Tests Locally

```sh
# Run tests for one action
bats tests/unit/update-aws-ecs/

# Run all action test suites
for dir in tests/unit/*/; do bats --verbose-run "$dir"; done
```

See [TESTING.md](./TESTING.md) for installation instructions.
