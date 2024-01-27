# Job Info Action

The "Job Info" GitHub Action is designed to gather essential information about jobs, particularly focusing on branch, environment, and tag details. It's a comprehensive action that can be integrated into your workflow to streamline and automate the process of information retrieval.

## Description

The "Job Info" action allows you to extract and use the following information within your GitHub Actions workflow:

- __Branch__: Identifies the target branch for the job.
- __Environment__: Specifies the target environment where the job is running.
- __Tag__: Determines the commit tag associated with the job.

## Outputs

The action provides the following outputs, which can be used in subsequent steps in your workflow:

- `branch`: The target branch of the job.
- `env_name`: The target environment of the job.
- `tag`: The tag associated with the job.

## Usage

To use the "Job Info" action in your workflow, include it as a step:

```yaml
- name: Gather Job Information
  id: job_info
  uses: your-repo/job-info@v1
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

1) Get Environment:
    - Determines the environment based on the branch or tag name. Supports predefined environments (e.g., `dev`, `prod`, `qa`) and extracts environment names from specific tag patterns.

### Notes

For more information on GitHub Environments and their usage, refer to the official documentation.

## Integration

Integrate this action into your workflows to enhance automation, ensure consistent environment tagging, and streamline branch management across your CI/CD processes.

Remember to replace `your-repo/job-info@v1` with the actual path to your action if you host it in a specific repository. This README provides a comprehensive guide on how to integrate and leverage the "Job Info" action in your GitHub workflows.
