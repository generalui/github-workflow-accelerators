# Job Info Action

The "Job Info" GitHub Action is designed to gather essential information about jobs, particularly focusing on branch, environment, and tag details.
It's a comprehensive action that can be integrated into your workflow to streamline and automate the process of information retrieval.

## Description

The "Job Info" action allows you to extract and use the following information within your GitHub Actions workflow:

- __Branch__: Identifies the target branch for the job.
- __Environment__: Specifies the target environment where the job is running.
- __Tag__: Determines the commit tag associated with the job.

## Inputs

The action accepts the following inputs:

- `default_environment`:
  - __Description__: The default environment to return if the action is not able to determine an environment. Defaults to an empty string.
  - __Required__: No
  - __Default__: ''

## Outputs

The action provides the following outputs, which can be used in subsequent steps in your workflow:

- `branch`: The target branch of the job.
- `env_name`: The target environment of the job.
- `pr_branch`: The branch in a PR that will be merged to the target branch of the job.
- `tag`: The tag associated with the job.

## Usage

To use the "Job Info" action in your workflow, include it as a step:

```yaml
- name: Gather Job Information
  id: job_info
  uses: generalui/github-workflow-accelerators/.github/actions/job-info@1.0.0-job-info
  with:
    default_environment: dev
```

After including it, you can access the outputs using the `steps`` context:

```yaml
- name: Use Job Information
  run: |
    echo "Branch: ${{ steps.job_info.outputs.branch }}"
    echo "Environment: ${{ steps.job_info.outputs.env_name }}"
    echo "Tag: ${{ steps.job_info.outputs.tag }}"
```

## Details

### Steps

1) Get Tag:
    - Determines the tag based on the trigger and outputs it for further use.

1) Get Target Branch:
    - Extracts the target branch considering various scenarios (e.g., pull requests, tags).

1) Get PR (Pull Request) Branch:
    - Extracts the branch in a pull request that will be merged to the target branch.
    - Returns an empty string if not a Pull Request.

1) Get Environment:
    - Determines the environment based on the branch or tag name.
    Supports predefined environments (e.g., `dev`, `prod`, `qa`) and extracts environment names from specific tag patterns.

    - The job-info GitHub Action sets an `env_name` output variable to indicate the target environment for the current job.

    The `env_name` value is determined as follows:

    - For branches:
        - `main` branch maps to `prod`
        - `develop` branch maps to `dev`
        - `qa`, `sandbox`, `staging`, `test` branch names map to the corresponding environment name
        - All other branch names default to the `default_environment` input value
    - For tags:
        - Tags (Semantic Versions) like `1.0.3`, `2.1.4-beta`, `3.2.5a0+build2`, etc map to `prod`
        - Tags ending with `-dev`, `-qa`, `-sandbox`, `-staging`, and `-test` map to the corresponding environment
        - Otherwise defaults to the `default_environment` input value

    In summary:

    - `main` → `prod`
    - `develop` → `dev`
    - Named branches → corresponding env
    - Tags (Semantic Versions) like `1.0.3`, `2.1.4-beta`, `3.2.5a0+build2`, etc. → `prod`
    - Tagged branches → corresponding env
    - Else → `default_environment`

    This allows you to control the `env_name` value through the git ref the action is run against.
    The `default_environment` input acts as a fallback when no specific mapping is found.

### Notes

For more information on GitHub Environments and their usage, refer to the official documentation.

## Integration

Integrate this action into your workflows to enhance automation, ensure consistent environment tagging, and streamline branch management across your CI/CD processes.

---

This README provides a comprehensive guide on how to integrate and leverage the "Job Info" action in your GitHub workflows.
