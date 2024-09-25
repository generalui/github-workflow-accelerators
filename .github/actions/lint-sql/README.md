# Lint SQL Action

The "Lint SQL" GitHub Action is designed to perform linting on SQL files or directories containing SQL files, ensuring adherence to best practices and coding standards.

## Description

This action uses SQLFluff, a popular SQL linter, to analyze your SQL code.
It's highly configurable, allowing you to specify a particular version of SQLFluff,
choose the Python runtime,
and provide additional configuration for the linting process.

## Inputs

The action accepts the following inputs:

- `config`:
  - __Description__: Include additional config file.
  By default, the config is generated from the standard configuration files described in the documentation.
  This input allows you to specify an additional configuration file that overrides the standard configuration files.
  Note that the cfg format is required.
  - __Required__: No
  - __Default__: ''

- `path`:
  - __Description__: The path to a SQL file or directory to lint.
  This can be either a file ('path/to/file.sql'),
  a path ('directory/of/sql/files'),
  a single ('-') character indicating reading from stdin,
  or a dot/blank ('.'/' ') which will be interpreted as the current working directory.
  - __Required__: Yes

- `python-version`:
  - __Description__: The version of Python to use. Defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

- `sqlfluff-version`:
  - __Description__: The version of SQLFluff to use.
  If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: ''

## Usage

To use the "Lint SQL" action in your workflow, include it as a step:

```yaml
- name: Lint SQL Files
  uses: generalui/github-workflow-accelerators/.github/actions/lint-sql@1.0.0-lint-sql
  with:
    config: 'path/to/config.cfg' # Optional: Path to additional config
    path: 'path/to/sql/files' # Required: Path to SQL file or directory
    python-version: '3.8' # Optional: Specify Python version
    sqlfluff-version: '0.8.1' # Optional: Specify SQLFluff version
```

## Workflow Steps

1) __Checkout Code__:
    - Checks out the code in your repository so that it can be analyzed by SQLFluff.

1) __Setup Python__:
    - Sets up the Python environment using the specified version.

1) __Install SQLFluff__:
    - Installs SQLFluff, optionally locking it to a specific version.

1) Lint:
    - Runs SQLFluff lint on the specified path. If an additional config is provided, it's included in the linting process.

## Notes

- Ensure that the path to the SQL files or directories is correctly specified.
- If using an additional config file, ensure it's in the correct cfg format as expected by SQLFluff.
- The action is highly customizable, allowing you to lock in specific versions of both Python and SQLFluff, making it suitable for projects with specific requirements.

## Integration

Integrate this action into your workflows to ensure your SQL code remains clean, maintainable, and adheres to your coding standards.

---

This README provides a comprehensive guide on how to integrate and leverage the "Lint SQL" action in your GitHub workflows.
