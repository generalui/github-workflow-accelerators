# Promote Elastic Container Repository Image Action

The "Promote Image" GitHub Action promotes a Docker image from a lower environment (dev or staging) to a higher one (staging or prod) in an AWS ECR repository.

## Description

The Promote Image action performs the following:

- Assumes an IAM role to access the target ECR repository
- Gets the image manifest for the old image tag in the source environment
- Tags the image with a new tag for the target environment
- Adds a unique tag with timestamp to support rollbacks
- Handles errors and exits gracefully

This allows you to automatically promote Docker images across environments in AWS ECR.

## Inputs

The action accepts the following inputs:

- `aws_access_key_id` - AWS access key ID for credentials. Optional.
- `aws_secret_access_key` - AWS secret access key for credentials. Optional.
- `aws_default_region` - AWS region for ECR. Optional.
- `aws_account` - AWS account ID for ECR. **Required**.
- `ecr` - ECR repository name. **Required**.
- `ecr_access_role_name` - IAM role name to access ECR. **Required**.
- `ecr_tag_name` - Tag name prefix for images. **Required**.
- `environment` - Target environment to promote to. **Required**.
- `lower_aws_account` - The AWS account ID to use for the lower environment.
If this is NOT provided, the action will assume the image is in the same ECR repository as the higher environment.
**Optional**.
- `lower_aws_default_region` - The AWS region to use for the lower environment.
If this is NOT provided, the action will assume the image is in the same ECR repository as the higher environment.
**Optional**.
- `lower_ecr` - The ECR repository to use for the lower environment.
If this is NOT provided, the action will assume the image is in the same ECR repository as the higher environment.
**Optional**.
- `lower_ecr_access_role_name` - The name of the role to assume to access the lower environment ECR repository.
If this is NOT provided, the action will assume the image is in the same ECR repository as the higher environment.
**Optional**.

## Outputs

The action provides the following outputs, which can be used in subsequent steps in your workflow:

- `branch`: The target branch of the job.
- `env_name`: The target environment of the job.
- `pr_branch`: The branch in a PR that will be merged to the target branch of the job.
- `tag`: The tag associated with the job.

## Usage

To use the "Promote Image" action in your workflow:

```yaml
- name: Promote to Production
  uses: generalui/github-workflow-accelerators/.github/actions/promote-image@1.0.0-promote-image
  with:
    aws_account: ${{ secrets.AWS_ACCOUNT_ID }}
    ecr: my-ecr-repo
    ecr_access_role_name: EcrAccessRole
    ecr_tag_name: app
    environment: prod
```

## Details

### Steps

1) Should Configure AWS:
    - Checks if AWS credentials are provided.

1) Configure AWS credentials:
    - Configures AWS credentials if it was determined that it is needed in the previous step.

1) Get lower branch:
    - Determines the lower branch based on the target environment (dev for staging, staging for prod).

1) Promote image:

    If the images are in different accounts or regions:
    1) Assumes the IAM role to access ECR repository.
    1) Pulls the image from the lower environment.
    1) Adds a unique timestamped tag to the image to support rollbacks.
    1) Pushes the tagged image to the target environment.
    1) Adds a "latest" tag to the image.
    1) Pushes the tagged image to the target environment.
    1) Handle errors and exit gracefully.
    1) Cleans up permissions and credentials at the end.

    If the images are in the same account and region:

    1) Assumes the IAM role to access ECR repository.
    1) Gets the image manifest for old tag in the source environment.
    1) Adds a unique tag with a timestamp to support rollbacks.
    1) Adds the new tag for the target environment to the image.
    1) Handle errors and exit gracefully.
    1) Cleans up permissions and credentials at the end.

### Notes

- For more on AWS ECR access roles, see the [ECR docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-policies.html).
- Uses helper scripts from the GitHub repo for AWS utilities.
- Exits with error if manifest fetch or image tagging fails.
- Requires [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
and [jq](https://jqlang.github.io/jq/) to be installed on runner

---

This README provides a comprehensive guide on how to integrate and leverage the "Promote Image" action in your GitHub workflows.
