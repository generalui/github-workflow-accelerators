# Lint & Test Action

The "Lint & Test" GitHub Action is designed to automate the process of linting and testing your JavaScript or TypeScript project,
ensuring code quality and functionality before integration into the main branch.

## Description

This action sets up your Node.js environment, installs dependencies, lints your project's code, and runs unit tests.
It's a comprehensive solution for maintaining code quality standards and ensuring that new commits don't introduce bugs.

## Inputs

The action accepts the following inputs:

- `branch`:
  - __Description__: The branch that is being tested. If not specified, defaults to the current branch.
  - __Required__: No
  - __Default__: ''

- `checkout-code`:
  - __Description__: Whether or not to checkout the code.
  - __Required__: No
  - __Default__: 'yes'

- `node-version`:
  - __Description__: The version of Node.js to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

- `run-before-tests`:
  - __Description__: A shell command to run before tests.
  - __Required__: No
  - __Default__: ''

- `should-run-lint`:
  - __Description__: Whether or not to lint. Anything other than 'yes' will skip linting.
  - __Required__: No
  - __Default__: 'yes'

- `should-run-tests`:
  - __Description__: Whether or not to run tests. Anything other than 'yes' will skip tests.
  - __Required__: No
  - __Default__: 'yes'

- `upload-coverage`:
  - __Description__: Whether or not to upload coverage as an artifact. Anything other than 'yes' will skip uploading. Assumes that the test command is `yarn test:coverage` if true.
  - __Required__: No  
  - __Default__: 'No'

- `yarn-version`:
  - __Description__: The version of Yarn to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

## Usage

To use the "Lint & Test" action in your workflow, include it as a step:

```yaml
- name: Lint & Test
  uses: generalui/github-workflow-accelerators/.github/actions/lint-test-yarn@1.0.1-lint-test-yarn
  with:
    node-version: '23.0.0' # Optional: Specify Node.js version
    yarn-version: '3.8.5' # Optional: Specify Yarn version
```

## Workflow Steps

1) Get Branch:
    - If `branch` is not specified, defaults to the current branch.

1) Checkout Code:
    - Checks out your code from the repository to ensure the latest version is used for linting and testing.

1) Setup Node.js:
    - Sets up a Node.js environment using the specified version and configures caching for Yarn, speeding up the installation of dependencies.

1) Install Dependencies:
    - Prints the requested and actual versions of Node.js.
    - Checks and sets the Yarn version according to the specified input.
    - Prints the initial, requested, and actual versions of Yarn.
    - Installs project dependencies using Yarn, ensuring consistency with the lockfile.

1) Lint Project:
    - Runs the linting script defined in your package.json, ensuring your code adheres to defined coding standards.

1) Run Before Tests:
    - Runs the command specified in the `run-before-tests` input.

1) Run Unit Tests:
    - Executes unit tests using the test script from your package.json.
    The --passWithNoTests flag ensures that the workflow doesn't fail if no tests are defined.

1) Get Coverage:
    - If `upload-coverage` is true, this step will create a directory with the branch name, and copy the coverage data into it.

1) Upload Coverage:
    - If `upload-coverage` is true, this step will upload the coverage data as an artifact.

1) Default Job Success:
    - If `should-run-tests` and `should-run-lint` are not true, this step will exit successfully.

## Notes

- The action is versatile and can be adapted to various Node.js and Yarn-based projects.
- It ensures that both the linting and testing stages must pass before a merge or deployment, enhancing code reliability.
- The action uses the --immutable flag with yarn install to prevent accidental updates to the lockfile, ensuring consistency across installations.
- The action assumes that the test command is `yarn test` if `upload-coverage` is false.
- The action assumes that the test command is `yarn test:coverage` if `upload-coverage` is true.

## Integration

Integrate this action into your CI/CD pipeline to automatically enforce coding standards and run tests on every push or pull request.
This action helps maintain high code quality and catch issues early in the development process.

---

This README provides a comprehensive guide on how to integrate and leverage the "Lint & Test" action in your GitHub workflows.
