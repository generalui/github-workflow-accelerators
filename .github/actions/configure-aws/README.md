# Configure AWS GitHub Action

## Overview

This GitHub action configures AWS credentials for the GitHub Actions runner.

It sets the AWS credentials and default region using the aws configure command with the provided access key, secret key, and default region.
The credentials are configured for the 'default' profile and are removed (converted to "XXX") after the workflow completes.

## Inputs

- `aws_access_key_id` - Required. The AWS access key ID to use.
- `aws_secret_access_key` - Required. The AWS secret access key to use.
- `aws_default_region` - Required. The AWS region to use.

## Example Usage

```yml
uses: ohgod-ai/eo-actions/.github/actions/configure-aws@configure-aws-1.0.0
with:
  aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
  aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  aws_default_region: us-east-1
```

This will configure the AWS credentials for the runner using the provided access key, secret key, and default region of `us-east-1`.

## How it Works

The action runs the following steps:

1. Configures AWS credentials using aws configure
1. Removes AWS credentials after workflow completes

The credentials are configured for the 'default' profile and removed by setting the keys to empty strings.

## Notes

- Credentials are configured for the default profile
- Credentials are removed after the workflow completes
- Requires the AWS CLI to be installed on the runner
- AWS credentials are re-written to "XXX" at the end of the job.
