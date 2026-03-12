# lint-test-yarn

**Path:** `.github/actions/lint-test-yarn`

Runs lint and unit tests for a Node.js project managed with Yarn. Supports optional code coverage upload, custom pre-test commands, and selective skip of lint or tests.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `node-version` | ❌ | `latest` | Node.js version to install. |
| `yarn-version` | ❌ | `latest` | Yarn version to use. |
| `branch` | ❌ | `''` | Branch name used when naming the coverage artifact. Defaults to the current branch. |
| `checkout-code` | ❌ | `yes` | Set to anything other than `yes` to skip checkout (useful when code was already checked out by a prior step). |
| `run-before-tests` | ❌ | `''` | Shell command to run before the test step (e.g. starting a local server). |
| `should-run-lint` | ❌ | `yes` | Set to anything other than `yes` to skip linting. |
| `should-run-tests` | ❌ | `yes` | Set to anything other than `yes` to skip tests. |
| `upload-coverage` | ❌ | `no` | Set to `yes` to upload the coverage directory as a workflow artifact. Requires `yarn test:coverage` to exist. |

## Outputs

None.

## Usage

### Lint and test (defaults)

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-test-yarn@<ref>
  with:
    node-version: '20'
```

### Lint only (skip tests)

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-test-yarn@<ref>
  with:
    node-version: '20'
    should-run-tests: 'no'
```

### Tests with coverage upload

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-test-yarn@<ref>
  with:
    node-version: '20'
    upload-coverage: 'yes'
    branch: ${{ github.head_ref }}
```

### Skip checkout (code already checked out)

```yaml
- uses: actions/checkout@v4

- uses: generalui/github-workflow-accelerators/.github/actions/lint-test-yarn@<ref>
  with:
    checkout-code: 'no'
    node-version: '20'
```

## How It Works

1. Optionally checks out the repository.
2. Installs the requested Node.js version (with Yarn cache enabled).
3. Sets the Yarn version and runs `yarn install --immutable`.
4. Runs `yarn lint` if `should-run-lint == 'yes'`.
5. Runs an optional pre-test command.
6. Runs `yarn test --passWithNoTests` (or `yarn test:coverage --passWithNoTests` when `upload-coverage == 'yes'`).
7. If coverage upload is requested, sanitises the branch name (replaces special chars with `-`), copies the `coverage/` directory, and uploads it as an artifact named `<branch>-test-coverage`.

## Coverage Artifact

The artifact is named `<sanitised-branch>-test-coverage` and stored for the workflow's default retention period.

The `coverage/` directory must be produced by your test command (e.g. via Jest's `--coverage` flag in your `test:coverage` script).

## Notes

- `yarn install --immutable` ensures the lockfile is not modified in CI — commit your `yarn.lock`.
- If both `should-run-lint` and `should-run-tests` are not `yes`, the action exits 0 (no-op) via an explicit `exit 0` step.
- The Yarn cache is keyed via `actions/setup-node`, which uses the `yarn.lock` file.

## Dependencies

- Node.js (installed via `actions/setup-node@v4`).
- Yarn (assumed already available or set via `yarn set version`).
