# Code Quality Workflow

The `code-quality.yml` workflow is the PR gate for this repository. It runs automatically on every pull request targeting `main`.

## What It Does

The workflow runs a single `quality` job with conditional steps:

1. **Detect changes** — uses `tj-actions/changed-files` to determine which files changed
2. **Lint Markdown** — runs `markdownlint-cli2` if any `.md` files or the workflow file itself changed
3. **Install bats** — installs the test runner if any action or test files changed
4. **Per-action tests** — runs `bats tests/unit/{action-name}/` for each action whose files changed

Only the steps relevant to the PR's changes are executed, keeping runner time minimal.

## Triggering Conditions

| Step | Triggers when... |
|------|-----------------|
| Lint Markdown | Any `**/*.md` file or `code-quality.yml` itself changed |
| bats tests | Files changed in `.github/actions/{action-name}/` or `tests/unit/{action-name}/` |

## Per-Action Test Detection

The workflow maintains an explicit list of actions that have bats test suites:

```yaml
actions_with_tests=(
  "promote-ecr-image"
  "test-python"
  "update-aws-ecs"
  "update-aws-lambda"
)
```

When adding a new action with testable shell scripts, add its name to this array. See [ADDING_AN_ACTION.md](./ADDING_AN_ACTION.md).

## Single-Job Design

All steps run sequentially in one job rather than as parallel matrix jobs. For fast-running bats suites, the overhead of spinning up multiple runners exceeds any parallelism benefit.

## Required Status Check

The `Quality` check produced by this workflow is a required status check on `main`. A PR cannot be merged until it passes.
