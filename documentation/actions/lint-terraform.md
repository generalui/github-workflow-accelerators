# lint-terraform

**Path:** `.github/actions/lint-terraform`

Lints all Terraform files in the repository using `terraform fmt -check`. Fails the job if any file is not formatted according to canonical Terraform style.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `terraform-version` | ❌ | `latest` | Terraform version to install (e.g. `1.6.0`). |

## Outputs

None.

## Usage

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-terraform@<ref>
```

### Pin a specific Terraform version

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-terraform@<ref>
  with:
    terraform-version: '1.6.0'
```

## How It Works

1. Checks out the repository with full history.
2. Installs Terraform via `hashicorp/setup-terraform@v2`.
3. Runs `terraform fmt -check -recursive -diff` from the repository root.
   - `-check` — exits non-zero if any file needs reformatting (no changes are written).
   - `-recursive` — processes all subdirectories.
   - `-diff` — prints a diff of the changes that *would* be made, helping developers fix issues quickly.

## Notes

- This action only **checks** formatting; it does not modify files. Developers must run `terraform fmt` locally and commit the result.
- Combine with `validate-terraform` for comprehensive Terraform quality gates.

## Dependencies

- Terraform (installed via `hashicorp/setup-terraform@v2`).

## See Also

- [validate-terraform](./validate-terraform.md)
