# Lint Terraform Action

The "Lint Terraform" GitHub Action is designed to enforce coding standards and ensure the consistency of Terraform code by linting all Terraform files in your repository.

## Description

This action uses terraform fmt, a built-in Terraform command, to check the formatting of your Terraform files.
It's a simple yet powerful tool to ensure that your code adheres to a consistent style and to catch common mistakes.

## Inputs

The action accepts the following input:

- `terraform-version`:
  - __Description__: The version of Terraform to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

## Usage

To use the "Lint Terraform" action in your workflow, include it as a step:

```yaml
- name: Lint Terraform Files
  uses: ohgod-ai/eo-actions/.github/actions/lint-terraform@lint-terraform-1.0.0
  with:
    terraform-version: '1.0.0' # Optional: Specify Terraform version
```

## Workflow Steps

1) __Checkout Code__:
    - Checks out your code from the repository to ensure the latest version of your Terraform files are linted.

1) __Setup Terraform__:
    - Sets up the Terraform environment using the specified version.
    This step ensures that you're linting your code with the exact version of Terraform that you're using for development and deployment.

1) __Lint Project__:
    - Runs terraform fmt in check mode, which scans all the Terraform files in your repository.
    It ensures they are correctly formatted without making any changes to the files.
    The -recursive flag ensures all files are checked recursively in directories.
    The -diff flag indicates what changes would be made to each file.

## Notes

- The action is designed to be simple and focused.
It's best suited for workflows where maintaining code quality and consistency in Terraform files is a priority.
- If any files are not formatted according to Terraform's standards, this step will fail, and it will show you what changes would need to be made.

## Integration

Integrate this action into your workflows to automatically ensure that your Terraform code is cleanly formatted and adheres to best practices.
This action is an excellent addition to any CI/CD pipeline, helping maintain high code quality and prevent formatting issues from making it into production.

---

This README provides a comprehensive guide on how to integrate and leverage the "Lint Terraform" action in your GitHub workflows.
