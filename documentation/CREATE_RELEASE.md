# Create Release Workflow

The `create-release.yml` workflow automatically creates versioned git tags and GitHub Releases when changes are merged to `main`.

## How It Works

1. **Detect changed files** — uses `tj-actions/changed-files` to identify which files changed in the push
2. **Extract action paths** — parses changed file paths to identify which action directories were modified
3. **Validate versions** — reads `project.json` from each changed action and verifies the version tag does not already exist
4. **Tag and release** — for each changed action, creates a git tag and GitHub Release with an auto-generated changelog

## Version Tag Format

Tags follow the format `{version}-{action-name}`:

```
1.0.1-update-aws-ecs
1.2.0-lint-test-yarn
```

The changelog is generated from commit messages between the previous tag and the new one.

## What Triggers a Release

A push to `main` triggers a release for any action whose files changed **and** whose `project.json` version is higher than the most recent tag for that action.

If the version has not been bumped, the workflow fails with:

```
The tag {version}-{action-name} already exists, ensure you have incremented the version in project.json.
```

Always bump `project.json` before merging. See [UPDATING_AN_ACTION.md](./UPDATING_AN_ACTION.md).

## What Does NOT Trigger a Release

The following paths are excluded from change detection:

| Path | Reason |
|------|--------|
| `.github/workflows/create-release.yml` | Self-referential |
| `.github/workflows/code-quality.yml` | Workflow-only change |
| `.github/**/*.md` | Workflow documentation |
| `documentation/**` | Documentation only |
| `tests/**` | Test files only |
| `*.md` | Root markdown files |
| `.vscode/**` | Editor config |
| `.gitignore`, `.markdownlint*`, `*.code-workspace` | Config files |

If you need to add a new top-level directory that should not trigger releases, add it to the `files_ignore` list in `create-release.yml`.

## Matrix Releases

If multiple actions change in a single merge, the workflow releases each one independently in parallel via a matrix strategy. Each action gets its own tag, changelog, and GitHub Release.
