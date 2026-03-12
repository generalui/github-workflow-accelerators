# DevOps

This document covers the CI/CD infrastructure for this repository.

## CI/CD Workflows

All workflows are defined in `.github/workflows/`.

| Workflow | Trigger | Purpose |
| ---------- | --------- | --------- |
| [`code-quality.yml`](./../.github/workflows/code-quality.yml) | PR to `main` | Linting and unit tests |
| [`create-release.yml`](./../.github/workflows/create-release.yml) | Push to `main` | Version tagging and GitHub Releases |

### Code Quality

See [CODE_QUALITY.md](./CODE_QUALITY.md) for details on the PR gate workflow.

### Create Release

See [CREATE_RELEASE.md](./CREATE_RELEASE.md) for details on the release workflow.

## Branch Protection

The `main` branch is protected:

- All changes must be submitted via pull request
- The `Quality` check (from `code-quality.yml`) must pass before merging
- Direct commits to `main` are blocked

## Dependency Management

Actions in this repo reference specific versions of external GitHub Actions (e.g. `actions/checkout@v6`).
When new versions are released — particularly those resolving runtime deprecation warnings — the `action.yml`
files and corresponding `project.json` versions should be updated. See [UPDATING_AN_ACTION.md](./UPDATING_AN_ACTION.md).
