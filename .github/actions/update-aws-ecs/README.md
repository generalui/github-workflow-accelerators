# Update AWS ECS GitHub Action

## Overview

This GitHub action updates an Amazon ECS service in a specified cluster.

It assumes a role to access the ECS cluster, updates the desired count of the service, and waits for the service to stabilize.

## Inputs

- `assume_ecs_access_role_arn` - Required. ARN of IAM role to assume to access ECS.
- `cluster` - Required. Name of the ECS cluster.
- `service` - Required. Name of the ECS service to update.
- `aws_access_key_id` - Optional. AWS access key ID for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.
- `aws_secret_access_key` - Optional. AWS secret access key for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.
- `aws_default_region` - Optional. AWS default region for credentials.
If this is NOT provided, the action will NOT set up AWS credentials; it is assumed they are already set up.

## Example Usage

```yml
uses: ohgod-ai/eo-actions/.github/actions/update-ecs@update-ecs-1.0.0
with:
  assume_ecs_access_role_arn: arn:aws:iam::123456789012:role/ecsAccessRole
  cluster: my-cluster
  service: my-service
```

This will update the ECS service my-service in cluster my-cluster using the provided role to access ECS.

## How it Works

The action runs the following steps:

1. Checks if AWS credentials need to be configured
1. Configures AWS credentials if provided
1. Assumes provided IAM role to access ECS
1. Updates desired count of ECS service to force new deployment
1. Waits for service to stabilize in new state

The ECS service is updated by setting a new timestamp on the service.
This forces a new deployment of the latest task definition.

## Notes

- Requires AWS credentials configured if not provided to action
- Credentials are configured for the default profile if provided
- Credentials are removed after workflow completes if configured
- Requires AWS CLI and jq to be installed on runner
