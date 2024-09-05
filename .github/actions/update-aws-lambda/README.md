# Update AWS Lambda GitHub Action

## Overview

This GitHub action updates the image used in an AWS Lambda.

It assumes a role to acquire permissions to update the Lambda.

## Inputs

- `assume_lambda_update_role_arn` - Required. ARN of IAM role to assume to update the Lambda.
- `function_name` - Required. Name of the Lambda.
- `image_url` - Required. The URL of the image to use in the Lambda.
- `aws_access_key_id` - Optional. AWS access key ID for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.
- `aws_secret_access_key` - Optional. AWS secret access key for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.
- `aws_default_region` - Optional. AWS default region for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.

## Example Usage

```yml
uses: ohgod-ai/eo-actions/.github/actions/update-aws-lambda@update-aws-lambda-1.0.0
with:
  assume_lambda_update_role_arn: arn:aws:iam::123456789012:role/updateLambda
  function_name: my-lambda
  image_url: 123456789098.dkr.ecr.us-west-2.amazonaws.com/my-ecr:latest
```

This will update the image in the lambda using the provided role.

## How it Works

The action runs the following steps:

1. Checks if AWS credentials need to be configured
1. Configures AWS credentials if provided
1. Assumes provided IAM role to acquire permissions
1. Updates the Lambda with provided image URL

This forces the Lambda to pull the image again even if the name of the image hasn't changed.

## Notes

- Requires AWS credentials configured if not provided to action
- Credentials are configured for the default profile if provided
- Credentials are removed after workflow completes if configured
- Requires AWS CLI and jq to be installed on runner
