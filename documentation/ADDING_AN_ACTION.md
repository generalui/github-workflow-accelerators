# Adding an Action

This guide covers how to add a new reusable composite action to this repository.

## Directory Structure

Each action lives in its own directory under `.github/actions/`:

```text
.github/actions/{action-name}/
├── action.yml        # Composite action definition (required)
├── project.json      # Version metadata (required)
├── README.md         # Action documentation (required)
└── scripts/          # Shell scripts invoked by action.yml (if needed)
    └── {script}.sh
```

## Step-by-Step

### 1. Create the action directory

Use kebab-case for the directory name. It becomes part of the version tag and the consumer's `uses:` reference.

```sh
mkdir -p .github/actions/my-new-action/scripts
```

### 2. Create `action.yml`

Define the action as a composite action. All actions in this repo use `using: composite`.

```yaml
name: My New Action

description: A brief description of what this action does.

inputs:
  my_input:
    description: Description of the input.
    required: true

runs:
  using: composite
  steps:
    - name: Run script
      env:
        MY_INPUT: ${{ inputs.my_input }}
      run: ${{ github.action_path }}/scripts/my_script.sh
      shell: bash
```

Key conventions:

- Pass inputs to shell scripts via environment variables, not positional arguments
- Use `${{ github.action_path }}` to reference scripts relative to the action
- Reference internal actions (e.g. `configure-aws`) by pinning to a release tag:
  `uses: generalui/github-workflow-accelerators/.github/actions/configure-aws@{tag}`

### 3. Create `project.json`

Start at version `1.0.0`. This file is read by the release workflow to create a version tag on merge to `main`.

```json
{
    "name": "my-new-action",
    "version": "1.0.0"
}
```

The `name` field must match the directory name exactly.

### 4. Create `README.md`

Document the action's inputs, outputs, and a usage example. See any existing action README for the expected format.

### 5. Write shell scripts (if applicable)

Place scripts in the `scripts/` directory. Follow the patterns established in existing scripts:

- Use `#!/usr/bin/env bash`
- Guard required environment variables at the top before doing any work
- Source `scripts/general/options_helpers.sh` if the script accepts CLI flags
- Exit with code `1` on validation failure (makes testing straightforward)

### 6. Write tests (if the action contains testable shell scripts)

See [WRITING_TESTS.md](./WRITING_TESTS.md) for the full guide.

Then register the action in the `actions_with_tests` array in `.github/workflows/code-quality.yml`:

```yaml
actions_with_tests=(
  "my-new-action"
  ...
)
```

### 7. Open a pull request

The `code-quality.yml` PR gate will run markdownlint and, if registered, the bats test suite for your new action.

On merge to `main`, `create-release.yml` will automatically create a git tag `1.0.0-my-new-action` and a GitHub Release.

## Versioning

New actions always start at `1.0.0`. See [UPDATING_AN_ACTION.md](./UPDATING_AN_ACTION.md) for version bump rules when making subsequent changes.
