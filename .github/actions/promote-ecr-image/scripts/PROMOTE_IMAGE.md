# Promote Image Script

This Bash script is designed to promote a Docker image from a lower environment (e.g., dev or staging)
to a higher environment (e.g., staging or prod) in an AWS Elastic Container Registry (ECR) repository.

## Prerequisites

- The configured AWS user must have credentials configured in the credentials files (see: <https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html>).
- The following environment variables must be set:
  - `AWS_ACCOUNT`: The AWS account ID for the target environment.
  - `AWS_DEFAULT_REGION`: The AWS region for the target environment.
  - `ENVIRONMENT`: The target environment (e.g., prod or staging).
  - `ECR`: The name of the ECR repository for the target environment.
  - `ECR_ACCESS_ROLE_NAME`: The name of the IAM role to assume to access the ECR repository for the target environment.
  - `ECR_TAG_NAME`: The prefix of the tag to promote.
  - `LOWER_AWS_ACCOUNT`: The AWS account ID for the lower environment.
  - `LOWER_AWS_DEFAULT_REGION`: The AWS region for the lower environment.
  - `LOWER_BRANCH`: The branch name for the lower environment.
  - `LOWER_ECR`: The name of the ECR repository for the lower environment.
  - `LOWER_ECR_ACCESS_ROLE_NAME`: The name of the IAM role to assume to access the ECR repository for the lower environment.

## Usage

```sh
./promote_image.sh [OPTIONS]
```

### Options

- `-h`, `--help`: Display the help message.

## Functionality

1. The script checks if the required environment variables are set. If any of them are empty, it exits with an error message.
2. It generates a timestamp and constructs the necessary tags for the target and lower environments.
3. It assumes the IAM role for the lower environment ECR and logs in to the ECR.
4. It pulls the Docker image with the latest tag from the lower environment ECR.
5. It cleans up the AWS credentials and permissions.
6. It assumes the IAM role for the target environment ECR and logs in to the ECR.
7. It tags the pulled image with a unique tag (including the timestamp) and the latest tag for the target environment.
8. It pushes the tagged images to the target environment ECR.
9. It cleans up the AWS credentials and permissions.

## Notes

- The script uses helper scripts from the `general` directory for common AWS operations, such as assuming roles and unsetting credentials.
- If any step fails, the script exits with an appropriate error message.
