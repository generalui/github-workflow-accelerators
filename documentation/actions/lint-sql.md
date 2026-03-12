# lint-sql

**Path:** `.github/actions/lint-sql`

Lints SQL files using [SQLFluff](https://docs.sqlfluff.com/). Checks out the repository, installs the requested version of SQLFluff, and runs `sqlfluff lint` against the specified path.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `path` | ✅ | — | Path to a SQL file or directory to lint. Use `.` for the entire repository. |
| `config` | ❌ | `''` | Path to an additional SQLFluff config file (`.cfg` format) that overrides the standard configuration. |
| `python-version` | ❌ | `latest` | Python version to install (passed to `actions/setup-python`). |
| `sqlfluff-version` | ❌ | `''` | SQLFluff version to install (e.g. `2.3.0`). Defaults to the latest published version. |

## Outputs

None.

## Usage

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-sql@<ref>
  with:
    path: ./sql
```

### Pin a specific SQLFluff version

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-sql@<ref>
  with:
    path: ./sql
    sqlfluff-version: '2.3.0'
    python-version: '3.11'
```

### Provide a custom config

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/lint-sql@<ref>
  with:
    path: ./sql
    config: ./.sqlfluff
```

## Notes

- The action always does a full `git fetch` (`fetch-depth: 0`) so SQLFluff can diff against the base branch if configured to do so.
- SQLFluff respects a `.sqlfluff` config file in the repository root automatically; the `config` input is for an **additional** override file only.

## Dependencies

- Python (installed via `actions/setup-python@v5`).
- `pip` (bundled with Python).
