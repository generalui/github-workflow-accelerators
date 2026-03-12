# CLAUDE.md — AI Assistant Context

This file provides context for AI coding assistants (Claude, Cursor, GitHub Copilot).
For full documentation, see the [`documentation/`](./documentation/) directory.

## What This Repository Is

A mono-repo of reusable [composite GitHub Actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action)
used across GenUI's CI/CD pipelines. All actions are composite actions (YAML + shell scripts) —
not Docker or JavaScript actions.

Consumers reference actions via:

```yaml
uses: generalui/github-workflow-accelerators/.github/actions/{action-name}@{version-tag}
```

## Repository Structure

```text
.github/
  actions/
    {action-name}/
      action.yml       # Composite action definition
      project.json     # Version — MUST be bumped on every change to this action
      README.md        # Action documentation
      scripts/         # Shell scripts invoked by action.yml
  workflows/
    code-quality.yml   # PR gate: markdownlint + per-action bats tests
    create-release.yml # Auto-releases on merge to main
tests/
  unit/
    {action-name}/     # bats tests for that action's shell scripts
  helpers/
    mock_helpers.bash  # Shared mock utilities
documentation/         # Contributor and DevOps guides
```

## Critical: Versioning Contract

**Every change to an action requires a `project.json` version bump. No exceptions.**

- Patch (1.0.0 → 1.0.1): bug fixes, dependency updates, documentation, refactors
- Minor (1.0.0 → 1.1.0): new optional inputs, backwards-compatible features
- Major (1.0.0 → 2.0.0): breaking changes to inputs or outputs

Skipping the version bump causes `create-release.yml` to fail on merge to `main` with a
"tag already exists" error.

See [UPDATING_AN_ACTION.md](./documentation/UPDATING_AN_ACTION.md).

## CI vs Release Triggers

**`code-quality.yml`** (PR gate) — runs on PRs to `main`:

- Markdownlint: fires when any `**/*.md` file changes
- bats tests: fires per-action when files in `.github/actions/{name}/` or `tests/unit/{name}/` change
- To add a new testable action, add its name to the `actions_with_tests` array in `code-quality.yml`

**`create-release.yml`** (release) — runs on push to `main`:

- Reads `project.json` from each changed action directory
- Ignores: `documentation/`, `tests/`, `*.md`, `.github/workflows/`, config files
- Creates tag `{version}-{action-name}` and GitHub Release per changed action

See [DEVOPS.md](./documentation/DEVOPS.md), [CODE_QUALITY.md](./documentation/CODE_QUALITY.md),
and [CREATE_RELEASE.md](./documentation/CREATE_RELEASE.md).

## Adding or Modifying Actions

- **Adding**: [ADDING_AN_ACTION.md](./documentation/ADDING_AN_ACTION.md)
- **Modifying**: [UPDATING_AN_ACTION.md](./documentation/UPDATING_AN_ACTION.md)
- **Testing**: [WRITING_TESTS.md](./documentation/WRITING_TESTS.md)
- **Contributing**: [CONTRIBUTING.md](./documentation/CONTRIBUTING.md)

## Key Conventions

- `main` is protected — all changes via PR; direct commits are blocked
- Shell scripts: `#!/usr/bin/env bash`, inputs passed via env vars not positional args
- Tests: bats, `REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"` (3 levels deep)
- Internal action references are pinned to a specific release tag
- New actions start at version `1.0.0`
