# update-aws-ecs

**Path:** `.github/actions/update-aws-ecs`

Forces a new deployment of an Amazon ECS service, causing ECS to pull the latest task definition and container image.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `assume_ecs_access_role_arn` | ✅ | — | Full ARN of the IAM role to assume for ECS access. |
| `cluster` | ✅ | — | ECS cluster name. |
| `service` | ✅ | — | ECS service name. |
| `aws_access_key_id` | ❌ | `''` | AWS access key ID. If omitted, assumes credentials are already configured. |
| `aws_secret_access_key` | ❌ | `''` | AWS secret access key. If omitted, assumes credentials are already configured. |
| `aws_default_region` | ❌ | `''` | AWS region. If omitted, assumes credentials are already configured. |

## Outputs

None.

## Usage

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/update-aws-ecs@<ref>
  with:
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws_default_region: us-east-1
    assume_ecs_access_role_arn: arn:aws:iam::123456789012:role/ecs-deploy-access
    cluster: production-cluster
    service: api-service
```

### Using pre-configured credentials (OIDC)

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions
    aws-region: us-east-1

- uses: generalui/github-workflow-accelerators/.github/actions/update-aws-ecs@<ref>
  with:
    assume_ecs_access_role_arn: arn:aws:iam::123456789012:role/ecs-deploy-access
    cluster: production-cluster
    service: api-service
```

## How It Works

1. Optionally configures AWS credentials (if `aws_access_key_id`, `aws_secret_access_key`, and `aws_default_region` are all provided).
2. Runs `scripts/update_ecs.sh`:
   - Clears any existing AWS credential env vars (`aws_unset.sh`).
   - Assumes the specified ECS access role via `sts:AssumeRole`.
   - Calls `aws ecs update-service --force-new-deployment` for the given cluster and service.
   - Exits 1 if the response is empty (indicating failure).
   - Clears credentials again on exit.

## Required IAM Permissions

The assumed role (`assume_ecs_access_role_arn`) needs:

```json
{
  "Effect": "Allow",
  "Action": ["ecs:UpdateService"],
  "Resource": "arn:aws:ecs:{region}:{account}:service/{cluster}/{service}"
}
```

The calling identity also needs `sts:AssumeRole` on the target role.

## Dependencies

- AWS CLI
- `jq`
