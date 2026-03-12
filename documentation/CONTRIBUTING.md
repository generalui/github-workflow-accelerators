# Contributing

Thank you for contributing to GitHub Workflow Accelerators. This document is the starting point for contributors — human or AI.

## Prerequisites

- [bats-core](https://github.com/bats-core/bats-core) — for running shell script tests locally
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) — for linting markdown
- [shellcheck](https://www.shellcheck.net/) — recommended for shell script authoring

See [LINTING.md](./LINTING.md) and [TESTING.md](./TESTING.md) for setup details.

## Guides

| Task | Document |
| ------ | ---------- |
| Add a new action | [ADDING_AN_ACTION.md](./ADDING_AN_ACTION.md) |
| Modify an existing action | [UPDATING_AN_ACTION.md](./UPDATING_AN_ACTION.md) |
| Write tests for shell scripts | [WRITING_TESTS.md](./WRITING_TESTS.md) |
| Understand CI/CD workflows | [DEVOPS.md](./DEVOPS.md) |

## Branch and PR Conventions

- `main` is a protected branch — all changes must go through a pull request
- Branch naming: `feat/`, `fix/`, `chore/` prefixes (e.g. `feat/add-notify-slack`)
- Each PR should change only the action(s) it intends to change
- PRs that change an action's files **must** include a `project.json` version bump — see [UPDATING_AN_ACTION.md](./UPDATING_AN_ACTION.md)

## Commit Messages

Use conventional commit prefixes:

- `feat:` — new action or new feature in an existing action
- `fix:` — bug fix
- `chore:` — dependency updates, version bumps, tooling changes
- `docs:` — documentation only changes
- `refactor:` — code changes that don't affect behaviour
- `test:` — adding or updating tests

## Code Review

- The `code-quality.yml` PR gate must pass before merging
- Markdownlint and bats tests run automatically for changed files — see [DEVOPS.md](./DEVOPS.md)
