# update-aws-lambda

**Path:** `.github/actions/update-aws-lambda`

Updates an AWS Lambda function's container image URI, triggering a redeployment with the new image.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `assume_lambda_update_role_arn` | ✅ | — | Full ARN of the IAM role to assume for Lambda update permissions. |
| `function_name` | ✅ | — | Name of the Lambda function to update. |
| `image_url` | ✅ | — | Full ECR image URI including tag (e.g. `123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:prod-latest`). |
| `aws_access_key_id` | ❌ | `''` | AWS access key ID. If omitted, assumes credentials are already configured. |
| `aws_secret_access_key` | ❌ | `''` | AWS secret access key. If omitted, assumes credentials are already configured. |
| `aws_default_region` | ❌ | `''` | AWS region. If omitted, assumes credentials are already configured. |

## Outputs

None.

## Usage

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/update-aws-lambda@<ref>
  with:
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws_default_region: us-east-1
    assume_lambda_update_role_arn: arn:aws:iam::123456789012:role/lambda-deploy
    function_name: my-payment-processor
    image_url: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:prod-latest
```

### Using pre-configured credentials (OIDC)

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/github-actions
    aws-region: us-east-1

- uses: generalui/github-workflow-accelerators/.github/actions/update-aws-lambda@<ref>
  with:
    assume_lambda_update_role_arn: arn:aws:iam::123456789012:role/lambda-deploy
    function_name: my-payment-processor
    image_url: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:prod-latest
```

## How It Works

1. Optionally configures AWS credentials (if all three credential inputs are provided).
2. Runs `scripts/update_lambda.sh`:
   - Clears any existing AWS credential env vars (`aws_unset.sh`).
   - Assumes the Lambda update role via `sts:AssumeRole`.
   - Calls `aws lambda update-function-code --function-name {name} --image-uri {url}`.
   - Exits 1 if the response is empty.
   - Clears credentials on exit.

## Required IAM Permissions

The assumed role (`assume_lambda_update_role_arn`) needs:

```json
{
  "Effect": "Allow",
  "Action": ["lambda:UpdateFunctionCode"],
  "Resource": "arn:aws:lambda:{region}:{account}:function:{function-name}"
}
```

The calling identity also needs `sts:AssumeRole` on the target role.

## Notes

- This action updates the **code image** only. To update environment variables, memory, timeout, or other configuration, use a separate step with the AWS CLI or CDK/Terraform.
- Lambda may take a few seconds to propagate the update; add a wait step after this action if subsequent steps depend on the new version being live.

## Dependencies

- AWS CLI
- `jq`
