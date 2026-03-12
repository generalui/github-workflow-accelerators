# Writing Tests

This guide covers how to write bats unit tests for shell scripts in this repository.
For running existing tests locally, see [TESTING.md](./TESTING.md).

## Framework

Tests use [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System).
The [bats-core documentation](https://bats-core.readthedocs.io/en/stable/) covers the full
test syntax, assertions, and built-in variables.

## What to Test

Tests cover the **shell scripts** inside each action's `scripts/` directory. Composite action
`action.yml` files use GitHub Actions expression syntax (`${{ inputs.xxx }}`) that cannot run
outside a real runner and are therefore out of scope for unit tests.

Good candidates for testing:

- Input validation (does the script exit 1 when a required env var is missing?)
- Core logic (does the script call the right CLI with the right arguments?)
- Edge cases (what happens with empty strings, missing optional vars, `--help`?)

## File Location

Tests live in `tests/unit/{action-name}/`, one directory per action. Each test file is named
`test_{script_name}.bats`. See existing tests for reference.

```text
tests/
└── unit/
    └── update-aws-ecs/
        └── test_update_ecs.bats
```

## Repo-Specific Conventions

### `BATS_TEST_DIRNAME` Depth

Tests are located at `tests/unit/{action-name}/test_*.bats` — three directory levels below
the repo root. Always use:

```bash
REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
```

### Mocking External Commands

External commands (`aws`, `pip`, `docker`, `tput`) must be mocked — tests must not make real
network calls. The standard pattern is to create lightweight mock executables in a temp
directory and prepend it to `PATH`. See any existing test file for the full mock setup pattern.

`tests/helpers/mock_helpers.bash` provides `setup_mocks`, `assert_mock_called_with`, and
`assert_mock_not_called` utilities.

**Do not re-export `PATH` inside `run bash -c "..."` subshells** — they inherit `PATH` from
`setup()` automatically. Overriding it in the subshell can break system tools like `dirname`.

### Testing Exit Codes

To assert a script exits with a non-zero code, use `run bash -c "..."`. `run` captures the
exit code in `$status` without causing the test to fail. See the
[bats-core docs](https://bats-core.readthedocs.io/en/stable/writing-tests.html#run-test-other-commands)
for details.

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
