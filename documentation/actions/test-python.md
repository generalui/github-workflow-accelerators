# test-python

**Path:** `.github/actions/test-python`

Runs Python unit tests using pytest (with coverage) or tox, optionally uploading the coverage report as a workflow artifact.

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `branch` | ✅ | — | Branch name used when naming the coverage artifact. |
| `python-version` | ❌ | `3.11.7` | Python version to install. |
| `checkout-code` | ❌ | `yes` | Set to anything other than `yes` to skip checkout. |
| `coverage-prefix` | ❌ | `''` | Prefix added to the coverage artifact name (avoids collisions in matrix jobs). |
| `global-index-url` | ❌ | `''` | Custom PyPI index URL (PEP 503). If provided, sets `global.index-url` in pip config. |
| `global-trusted-host` | ❌ | `''` | Trusted pip host. If provided, sets `global.trusted-host` in pip config. |
| `min-coverage` | ❌ | `0` | Minimum coverage percentage. Passed to pytest as `--cov-fail-under`. `0` disables the check. |
| `retention-days` | ❌ | `31` | Days to keep the coverage artifact. |
| `run-before-tests` | ❌ | `''` | Shell command to run before tests (e.g. start a local database). |
| `search-index` | ❌ | `''` | Custom PyPI search index URL. If provided, sets `search.index` in pip config. |
| `should-run-tests` | ❌ | `yes` | Set to anything other than `yes` to skip tests entirely. |
| `tox-version` | ❌ | `''` | Tox version to use. If provided, tox is used instead of pytest. |
| `upload-coverage` | ❌ | `yes` | Set to anything other than `yes` to skip coverage artifact upload. |

## Outputs

None.

## Usage

### Basic pytest run

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/test-python@<ref>
  with:
    branch: ${{ github.head_ref || github.ref_name }}
```

### With minimum coverage gate

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/test-python@<ref>
  with:
    branch: ${{ github.head_ref || github.ref_name }}
    min-coverage: 80
```

### With tox

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/test-python@<ref>
  with:
    branch: ${{ github.head_ref || github.ref_name }}
    tox-version: '4.11.3'
    python-version: '3.11.7'
```

### Custom PyPI index (private registry)

```yaml
- uses: generalui/github-workflow-accelerators/.github/actions/test-python@<ref>
  with:
    branch: ${{ github.head_ref || github.ref_name }}
    global-index-url: https://private.pypi.example.com/simple
    global-trusted-host: private.pypi.example.com
```

## How It Works

1. Optionally checks out the repository.
2. Sets up Python with pip caching keyed on `setup.cfg`, `setup.py`, `requirements-dev.txt`, and `requirements-test.txt`.
3. Configures pip (custom index URL / trusted host / search index) via `scripts/configure_pip.sh`.
4. Upgrades pip.
5. Installs dependencies:
   - **tox mode:** `pip install tox=={version}`
   - **pytest mode:** installs `requirements-test.txt` (falls back to `requirements-dev.txt`)
6. Runs an optional pre-test command.
7. Runs tests:
   - **tox mode:** `tox run -e coverage-py{major}{minor}`
   - **pytest mode:** `pytest --cov --cov-report html -n auto [--cov-fail-under=N]`
8. Uploads the `coverage/` directory as a workflow artifact named `{prefix}{branch}-test-coverage`.

## Coverage Artifact

- **Name pattern:** `{coverage-prefix}{sanitised-branch}-test-coverage`
- Branch names have `":<>|*?\\/` replaced with `-` to create a valid artifact name.
- The artifact contains the `htmlcov/` output from pytest-cov.

## Notes

- `should-run-tests != 'yes'` causes the action to exit 0 immediately (skips all steps).
- The `-n auto` flag requires `pytest-xdist` in your test requirements.

## Dependencies

- Python (installed via `actions/setup-python@v5`).
- `pytest`, `pytest-cov`, `pytest-xdist` (or tox) in your test requirements file.
