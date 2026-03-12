# Updating an Action

Every change to an action's files **requires a `project.json` version bump**. This is not optional — the release workflow reads `project.json` on every push to `main` and will fail with a "tag already exists" error if the version has not been incremented.

## Versioning Rules

This repository follows [Semantic Versioning](https://semver.org/):

| Change type | Version bump | Example |
|-------------|-------------|---------|
| Bug fix, dependency update, refactor, documentation | **Patch** | `1.0.0` → `1.0.1` |
| New optional input, backwards-compatible enhancement | **Minor** | `1.0.0` → `1.1.0` |
| Removed input, changed input name, changed behaviour | **Major** | `1.0.0` → `2.0.0` |

When in doubt, bump the patch version. A version bump is always cheaper than a failed release.

## How to Update an Action

### 1. Make your changes

Edit the relevant files in `.github/actions/{action-name}/` — `action.yml`, scripts, `README.md`, etc.

### 2. Bump `project.json`

```json
{
    "name": "my-action",
    "version": "1.0.1"
}
```

### 3. Update tests if needed

If you changed a shell script's behaviour or added new logic, update or add tests in `tests/unit/{action-name}/`. See [WRITING_TESTS.md](./WRITING_TESTS.md).

### 4. Open a pull request

The PR gate validates markdown and runs bats tests for the changed action. On merge to `main`, the release workflow creates the new version tag and GitHub Release automatically.

## Updating Dependencies

When a GitHub Action used inside an action's `action.yml` releases a new version, update the `uses:` reference and bump the patch version in `project.json`.

```yaml
# Before
uses: actions/checkout@v5

# After
uses: actions/checkout@v6
```

Check for Node.js deprecation warnings in GitHub Actions run logs — these indicate an action's runtime is approaching end-of-life.

## Updating Internal Action References

Actions that reference other actions in this repo (e.g. `configure-aws`) pin to a specific release tag:

```yaml
uses: generalui/github-workflow-accelerators/.github/actions/configure-aws@1.0.0-configure-aws
```

If `configure-aws` is updated, consumers should update their pinned tag in a separate PR with a corresponding version bump.

## What the Release Workflow Does

On every push to `main`, `create-release.yml`:

1. Detects which action directories changed (ignoring docs, tests, and workflow files)
2. Reads `project.json` from each changed action directory
3. Checks that the new version tag does not already exist (fails if it does)
4. Creates a git tag in the format `{version}-{action-name}` (e.g. `1.0.1-update-aws-ecs`)
5. Generates a changelog from commit messages
6. Creates a GitHub Release

See [DEVOPS.md](./DEVOPS.md) for more detail on the CI/CD workflows.
