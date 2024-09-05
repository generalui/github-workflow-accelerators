# Test Python Action

The "Test Python" GitHub Action is designed to automate testing for Python projects.
This action simplifies the process of setting up Python environments, checking out code, installing dependencies, and running tests.

## Description

This action runs coverage testing on a Python project.
This is very opinionated.
It assumes:

- you are using the `pytest` framework
- you have your test dependencies in a `requirement-dev.txt` file
- you have your test code in a `tests` directory
- you are using pip
- your project dependencies are defined in your `setup.cfg` file

## Inputs

The action accepts the following input:

- `branch`:
  - __Description__: The branch that is being tested.
  - __Required__: Yes

- `checkout-code`:
  - __Description__: Whether or not to checkout the code.
  - __Default__: 'yes'

- `global-index-url`:
  - __Description__: The base URL of the Python Package Index (default <https://pypi.org/simple>).
    This should point to a repository compliant with PEP 503 (the simple repository API) or a local directory laid out in the same format.
    If none is passed, the index URL will not be updated.
  - __Required__: No

- `global-trusted-host`:
  - __Description__: The host of the global trusted host to use for PIP.
    This will mark this host or host:port pair as trusted, even though it does not have valid or any HTTPS.
    If none is passed, the trusted host will not be updated.
  - __Required__: No

- `python-version`:
  - __Description__: The version of Python to use. Defaults to a specific version if not specified.
  - __Required__: No
  - __Default__: '3.11.7'

- `retention-days`:
  - __Description__: The number of days to keep artifacts.
  - __Required__: No
  - __Default__: 31

- `run-before-tests`:
  - __Description__: A shell command to run before tests.
  - __Required__: No
  - __Default__: ''

- `search-index`:
  - __Description__: The search index to use for PIP.
    Base URL of Python Package Index (default <https://pypi.org/pypi>).
    If none is passed, the search index will not be updated.
  - __Required__: No

- `should-run-tests`:
  - __Description__: Whether or not to run tests. Set this to anything other than "yes" to skip tests.
  - __Required__: No
  - __Default__: 'yes'

- `tox-version`:
  - __Description__: The version of Tox to use for testing. If not specified, `tox` will not be used and `pytest` will be called directly.
  - __Required__: No

- `upload-coverage`:
  - __Description__: Whether or not to upload coverage as an artifact. Set this to anything other than "yes" to skip uploading.
  - __Required__: No
  - __Default__: 'yes'

## Usage

To use the "Test Python" action in your workflow, include it as a step:

```yaml
- name: Test Python
  uses: ohgod-ai/eo-actions/.github/actions/test-python@test-python-1.0.0
  with:
    branch: ${{ github.ref_name }}
    global-index-url: 'http://sakura.ohgod.ai:3141/eo/stable/+simple/'
    global-trusted-host: 'sakura.ohgod.ai'
    python-version: '3.11.7'
    run-before-tests: 'echo "Hello World"'
    search-index: 'http://sakura.ohgod.ai:3141/eo/stable'
    should-run-tests: 'yes'
    tox-version: '4.12.1'
    upload-coverage: 'yes'
```

## Workflow Steps

1) __Set up Python__:
    - Sets up a Python environment with the specified version, if tests are to be run.

1) __Checkout code__:
    - Checks out the repository's code, if tests are to be run and the `checkout-code` input is set to 'yes'.

1) __Configure & Update pip__:
    - Configures and updates pip with the specified index URL, trusted host, and/or search index.
    - Updates pip to the latest version.

1) __Install Dependencies__:
    - If tests are to be run this installs the specified version of `tox`.
    If the `tox` version is NOT provided, it installs the test and app dependencies directly.

1) __Run Before Tests__:
    - Runs the specified shell command before tests.
    Only will run if tests are to be run and a shell command is provided via the `run-before-tests` input.

1) __Test__:
    - If tests are to be run this runs tests using `tox` (if the `tox` version is provided).
    Otherwise it runs tests using `pytest`.
    Once tests are complete, it uploads the coverage report.

1) __Get the coverage file__:
    - Copies the coverage information to a folder named after the branch, if tests are to be run and coverage is to be uploaded.

1) __Upload the Coverage as an artifact__:
    - Uploads the coverage report as an artifact, if tests are to be run and coverage is to be uploaded.

1) __Default Job Success__:
    - Ends the job successfully if tests are not to be run.

## Notes

- Ensure that the Python version specified is compatible with your project.
- If using `tox`, ensure the version specified is compatible with your project.
- The action is customizable to skip tests or coverage uploading by adjusting the `should-run-tests` and `upload-coverage` inputs respectively.
- Coverage reports are retained as artifacts for historical comparison and analysis.

---

This README provides a comprehensive guide on how to integrate and leverage the "Test Python" action in your GitHub workflows.
