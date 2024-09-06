# Lint & Test Action

The "Lint & Test" GitHub Action is designed to automate the process of linting and testing your JavaScript or TypeScript project,
ensuring code quality and functionality before integration into the main branch.

## Description

This action sets up your Node.js environment, installs dependencies, lints your project's code, and runs unit tests.
It's a comprehensive solution for maintaining code quality standards and ensuring that new commits don't introduce bugs.

## Inputs

The action accepts the following inputs:

- `node-version`:
  - __Description__: The version of Node.js to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

- `yarn-version`:
  - __Description__: The version of Yarn to use. If not specified, defaults to the latest version.
  - __Required__: No
  - __Default__: 'latest'

## Usage

To use the "Lint & Test" action in your workflow, include it as a step:

```yaml
- name: Lint and Test
  uses: ohgod-ai/eo-actions/.github/actions/lint-and-test@lint-and-test-1.0.0
  with:
    node-version: '14' # Optional: Specify Node.js version
    yarn-version: '1.22' # Optional: Specify Yarn version
```

## Workflow Steps

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

1) Run Unit Tests:
    - Executes unit tests using the test script from your package.json.
    The --passWithNoTests flag ensures that the workflow doesn't fail if no tests are defined.

## Notes

- The action is versatile and can be adapted to various Node.js and Yarn-based projects.
- It ensures that both the linting and testing stages must pass before a merge or deployment, enhancing code reliability.
- The action uses the --frozen-lockfile flag with yarn install to prevent accidental updates to the lockfile, ensuring consistency across installations.

## Integration

Integrate this action into your CI/CD pipeline to automatically enforce coding standards and run tests on every push or pull request.
This action helps maintain high code quality and catch issues early in the development process.

---

This README provides a comprehensive guide on how to integrate and leverage the "Lint & Test" action in your GitHub workflows.
