# validate-terraform

**Path:** `.github/actions/validate-terraform`

Validates Terraform configuration files using `terraform validate`. Runs `terraform init` then `terraform validate` across one or more directory paths.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `terraform-version` | ❌ | `latest` | Terraform version to install. |
| `paths` | ❌ | `./` | Newline-separated list of paths to validate. Each path must end with `/` (e.g. `infra/` or `infra/modules/vpc/`). |

## Outputs

None.

## Usage

### Validate the root module

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/validate-terraform@<ref>
```

### Validate multiple modules

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/validate-terraform@<ref>
  with:
    paths: |
      infra/
      infra/modules/vpc/
      infra/modules/rds/
```

### Pin a Terraform version

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/validate-terraform@<ref>
  with:
    terraform-version: '1.6.0'
    paths: infra/
```

## How It Works

1. Checks out the repository with full history.
2. Installs Terraform via `hashicorp/setup-terraform@v2`.
3. For each path in the `paths` input:
   - `cd` into the directory.
   - Runs `terraform init`.
4. For each path again:
   - `cd` into the directory.
   - Runs `terraform validate`.

The action exits with a non-zero code if any `init` or `validate` step fails.

## Notes

- `terraform init` downloads providers and modules — ensure your provider configurations are correct for CI (no backend authentication required for `validate`; use `terraform init -backend=false` patterns in your `.tf` files if needed).
- This action validates **syntax and internal consistency** only. It does not plan or apply changes, and does not require cloud credentials for the validation step itself.
- Combine with `lint-terraform` for a complete Terraform quality gate.

## Dependencies

- Terraform (installed via `hashicorp/setup-terraform@v2`).

## See Also

- [lint-terraform](./lint-terraform.md)
