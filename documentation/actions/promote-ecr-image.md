# promote-ecr-image

**Path:** `.github/actions/promote-ecr-image`

Promotes a Docker image from a lower environment (dev → staging, or staging → prod) within AWS ECR. Supports same-account and cross-account promotion.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `aws_account` | ✅ | — | AWS account ID of the **target** (higher) environment. |
| `ecr` | ✅ | — | ECR repository name in the target account. |
| `ecr_access_role_name` | ✅ | — | IAM role name to assume for ECR write access in the target account. |
| `ecr_tag_name` | ✅ | — | Tag prefix (e.g. `my-app`). The full tag is built as `{ecr_tag_name}-{environment}-latest`. |
| `environment` | ✅ | — | Target environment: `staging` or `prod`. |
| `aws_access_key_id` | ❌ | `''` | AWS access key ID. If omitted, assumes credentials are already configured. |
| `aws_secret_access_key` | ❌ | `''` | AWS secret access key. If omitted, assumes credentials are already configured. |
| `aws_default_region` | ❌ | `''` | AWS region. If omitted, assumes credentials are already configured. |
| `lower_aws_account` | ❌ | `''` | AWS account ID of the **source** (lower) environment. Omit if same account. |
| `lower_aws_default_region` | ❌ | `''` | AWS region of the source environment. Omit if same region. |
| `lower_ecr` | ❌ | `''` | ECR repository in the source account. Omit if same repository. |
| `lower_ecr_access_role_name` | ❌ | `''` | IAM role name for ECR access in the source account. Omit if same account. |

## Outputs

None.

## Promotion Logic

### Same-account promotion

When `lower_aws_account` and `lower_aws_default_region` are **not** provided, the action:

1. Resolves the lower environment tag (`{ecr_tag_name}-{lower_branch}-latest`).
2. Assumes the ECR write access role in the target account.
3. Fetches all tags associated with the source image.
4. Derives the timestamped tag from the existing tags (or generates a new one).
5. Copies the image manifest using `aws ecr put-image` to both:
   - `{ecr_tag_name}-{environment}-{timestamp}` (immutable snapshot)
   - `{ecr_tag_name}-{environment}-latest` (mutable pointer)

### Cross-account promotion

When `lower_aws_account` and `lower_aws_default_region` are provided, the action delegates to `scripts/promote_image.sh`, which:

1. Assumes the **source** account ECR role.
2. Logs in to the source ECR and pulls the image locally.
3. Resolves the timestamped tag from the source account's image metadata.
4. Assumes the **target** account ECR role.
5. Logs in to the target ECR and pushes both the timestamped and `latest` tags.

## Environment → Lower Branch Mapping

| `environment` | Lower branch |
|---------------|-------------|
| `staging` | `dev` |
| `prod` | `staging` |

## Usage

### Promote dev → staging (same account)

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/promote-ecr-image@<ref>
  with:
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws_default_region: us-east-1
    aws_account: '123456789012'
    ecr: my-app
    ecr_access_role_name: ecr-write-access
    ecr_tag_name: my-app
    environment: staging
```

### Promote staging → prod (cross-account)

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/promote-ecr-image@<ref>
  with:
    aws_account: '111111111111'
    ecr: my-app
    ecr_access_role_name: ecr-write-access
    ecr_tag_name: my-app
    environment: prod
    lower_aws_account: '222222222222'
    lower_aws_default_region: us-east-1
    lower_ecr: my-app
    lower_ecr_access_role_name: ecr-write-access
```

## Required IAM Permissions

The assumed role needs:

```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchGetImage",
    "ecr:PutImage",
    "ecr:DescribeImages"
  ],
  "Resource": "*"
}
```

Plus `sts:AssumeRole` on the calling identity.

## Dependencies

- AWS CLI
- Docker (cross-account promotion only)
- `jq`
