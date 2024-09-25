# Create Github Action Release Workflow

This workflow automates creating a release for new or updated Github action or workflow.

## Trigger

Pushing to the following branches trigger creating a release:

- `main`

## Jobs

The workflow contains 2 jobs:

1. Validate release - Ensures the version is new and unique for changed modules.

2. Release - Creates a releases for changed modules.

### Validate Releases

This job handles ensuring the versions are new and unique:

- Check out code
- Setup for creating a release
- Check if the tag to be created already exists.

### Releases

This job handles creating releases:

- Create new releases if it doesn't already exist.

## Notes

The "Validate releases" job uses the version of the module in the `project.json` file located in the root of each module.
If any of the versions have already been deployed, the job will fail.

If any of the tags already exist when the deployment is triggered by a push, the deploy will fail.
