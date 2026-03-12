# Documentation

Comprehensive reference documentation for all GitHub Actions in this repository.

## Actions

| Action | Description |
|--------|-------------|
| [configure-aws](./actions/configure-aws.md) | Configure AWS credentials on the runner |
| [job-info](./actions/job-info.md) | Derive branch, tag, PR branch, and environment from the GitHub context |
| [lint-sql](./actions/lint-sql.md) | Lint SQL files with SQLFluff |
| [lint-terraform](./actions/lint-terraform.md) | Lint Terraform with `terraform fmt` |
| [lint-test-yarn](./actions/lint-test-yarn.md) | Lint and test a Node.js project with Yarn |
| [promote-ecr-image](./actions/promote-ecr-image.md) | Promote a Docker image between ECR environments |
| [test-python](./actions/test-python.md) | Run Python tests with pytest or tox |
| [update-aws-ecs](./actions/update-aws-ecs.md) | Force-update an ECS service |
| [update-aws-lambda](./actions/update-aws-lambda.md) | Update an AWS Lambda function's container image |
| [validate-terraform](./actions/validate-terraform.md) | Validate Terraform configuration |

## Internal Scripts

Each AWS-facing action bundles a set of bash helper scripts under its `scripts/general/` directory.

| Script | Purpose |
|--------|---------|
| `options_helpers.sh` | Argument-parsing utilities (`has_argument`, `extract_argument`) |
| `aws_unset.sh` | Clears AWS credential environment variables |
| `assume_role.sh` | Calls `aws sts assume-role` and exports the credentials |
| `assume_ecr_write_access_role.sh` | Wraps `assume_role` for ECR write access |
| `assume_ecs_access_role.sh` | Wraps `assume_role` for ECS access |
| `assume_lambda_update_role.sh` | Wraps `assume_role` for Lambda update permissions |

> **Note:** `options_helpers.sh`, `aws_unset.sh`, and `assume_role.sh` are currently duplicated across the `promote-ecr-image`, `update-aws-ecs`, and `update-aws-lambda` actions. They are functionally identical.

## Testing

See [../tests/README.md](../tests/README.md) for information on running the unit test suite.
