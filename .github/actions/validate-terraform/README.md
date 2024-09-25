# Validate Terraform Action

The "Validate Terraform" GitHub Action is designed to validate your Terraform configurations, ensuring that they are syntactically valid and internally consistent.

## Description

This action sets up your Terraform environment with the specified version and iteratively validates multiple Terraform configurations in different directories.
It's an essential tool for maintaining the quality and reliability of your infrastructure as code.

## Inputs

The action accepts the following inputs:

- `terraform-version`:
  - __Description__: The version of Terraform to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

- `paths`:
  - __Description__: Newline-separated list of paths to validate.
  Paths must be formatted as `<folder>/` or `<folder>/<folder>/`.
  This allows you to validate multiple sets of Terraform configurations within a single workflow.
  - __Required__: No
  - __Default__: './'

## Usage

To use the "Validate Terraform" action in your workflow, include it as a step:

```yaml
- name: Validate Terraform Configurations
  uses: generalui/terraform-accelerator/.github/actions/validate-terraform@1.0.0-validate-terraform
  with:
    terraform-version: '1.7.2' # Optional: Specify Terraform version
    paths: | # Optional: Specify multiple paths
      terraform/project1/
      terraform/project2/
```

## Workflow Steps

1) Checkout Code:
    - Checks out your code from the repository to ensure the latest version of your Terraform configurations are validated.

1) Setup Terraform:
    - Sets up the Terraform environment using the specified version.

1) Initialize:
    - Iterates through the provided paths and runs terraform init in each directory.
    This step initializes the Terraform configuration which is a prerequisite for validation.

1) Validate:
    - Iterates through the provided paths and runs terraform validate in each directory.
    This step checks for syntax errors and internal consistency issues in your Terraform configurations.

## Notes

- The action is designed to handle multiple sets of Terraform configurations,
making it suitable for mono-repos or repositories containing multiple independently managed sets of infrastructure.
- It's important to ensure that the paths are correctly specified and that each path contains a valid Terraform configuration.
- The action ensures that your Terraform configurations are ready for further stages like planning and applying, enhancing the reliability of your CI/CD pipeline.

## Integration

Integrate this action into your CI/CD pipeline to automatically ensure that your Terraform configurations are valid and ready for deployment.
This action helps maintain high-quality infrastructure code and prevents potential issues from progressing through your pipeline.

---

This README provides a comprehensive guide on how to integrate and leverage the "Validate Terraform" action in your GitHub workflows.
