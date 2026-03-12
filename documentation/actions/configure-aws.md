# configure-aws

**Path:** `.github/actions/configure-aws`

Configures AWS credentials on the GitHub Actions runner by writing them into the default AWS CLI profile, then schedules a post-run cleanup step that scrubs those credentials after the job finishes.

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `aws_access_key_id` | ✅ | AWS access key ID |
| `aws_secret_access_key` | ✅ | AWS secret access key |
| `aws_default_region` | ✅ | AWS region (e.g. `us-east-1`) |

## Outputs

None.

## How It Works

1. Runs `aws configure set` to write the three credential values into `~/.aws/credentials` under the `default` profile.
2. Registers three **post-run** cleanup steps via `webiny/action-post-run@3.1.0` that overwrite the credential values with `"XXX"` once the job finishes — preventing credential leakage in log artifacts or subsequent steps.

## Usage

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/configure-aws@<ref>
  with:
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws_default_region: us-east-1
```

## Notes

- This action is used internally by `promote-ecr-image`, `update-aws-ecs`, and `update-aws-lambda` when AWS credentials are passed as inputs.
- If you are using OIDC-based authentication (e.g. `aws-actions/configure-aws-credentials`), you do **not** need this action.
- The post-run cleanup is best-effort; if the runner is forcibly terminated, cleanup may not execute.

## Dependencies

- AWS CLI must be available on the runner (`ubuntu-latest` includes it by default).
- `webiny/action-post-run@3.1.0` for scheduled post-step execution.
