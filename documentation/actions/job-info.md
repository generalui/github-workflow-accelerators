# job-info

**Path:** `.github/actions/job-info`

Derives contextual information about the current job — target branch, tag, PR branch, and deployment environment — from the GitHub Actions runtime context. Use this as an early step to get consistent environment names across all your workflows.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `default_environment` | ❌ | `''` | Fallback environment name when no branch/tag rule matches |

## Outputs

| Output | Description |
|--------|-------------|
| `branch` | The target branch (base branch for PRs; current branch for pushes) |
| `env_name` | The resolved deployment environment name |
| `pr_branch` | The source branch of a pull request (empty for non-PR events) |
| `tag` | The git tag that triggered the workflow, or `"none"` |

## Environment Mapping

### Branch → environment

| Branch | Environment |
|--------|------------|
| `develop` | `dev` |
| `main` | `prod` |
| `qa` | `qa` |
| `sandbox` | `sandbox` |
| `staging` | `staging` |
| `test` | `test` |
| anything else | `default_environment` input |

### Tag → environment

| Tag pattern | Environment |
|-------------|------------|
| `*-dev` | `dev` |
| `*-qa` | `qa` |
| `*-sandbox` | `sandbox` |
| `*-staging` | `staging` |
| `*-test` | `test` |
| semver (e.g. `1.2.3`, `1.2.3-rc.1`) | `prod` |
| anything else | unchanged (branch rule applies first) |

Tag rules take precedence over branch rules when both apply.

## Usage

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - id: info
        uses: generalui/github-workflow-accelerators/.github/actions/job-info@<ref>
        with:
          default_environment: dev

      - name: Deploy to ${{ steps.info.outputs.env_name }}
        run: echo "Deploying to ${{ steps.info.outputs.env_name }}"
```

## Notes

- For **pull_request** events, `branch` is the **base** (target) branch, not the head branch. Use `pr_branch` to get the source branch.
- For **push** events on a branch, `branch` is the branch name. `pr_branch` will be empty.
- For **tag push** events, `tag` contains the tag name and `env_name` is resolved from the tag pattern table above.
- The semver pattern matches `MAJOR.MINOR.PATCH` with optional pre-release/build metadata (e.g. `1.0.0`, `2.1.0-beta.1`, `3.0.0+build.42`).
