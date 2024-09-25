# Deploy to Elastic Beanstalk Action

The "Deploy to Elastic Beanstalk" GitHub Action automates the deployment of applications to AWS Elastic Beanstalk
directly from your GitHub repository, ensuring a seamless CI/CD pipeline for your cloud-based applications.

## Description

This action is triggered on pushes to the `develop` and `main` branches or can be manually triggered using `workflow_dispatch`.
It consists of two main jobs: gathering job information and deploying to AWS Elastic Beanstalk.
The deployment process includes building a deployment package (e.g., a JAR file for a Spring Java application) and deploying it to the specified Elastic Beanstalk environment.

## Workflow

### On Events

- `push`:
  - Triggers the workflow on pushes to the develop and main branches.

- `workflow_dispatch`:
  - Allows the workflow to be manually triggered.

### Jobs

1) Gather info for jobs (`info`):
    - Gathers essential information for subsequent jobs, like the environment name.
    - Uses the [job-info](https://github.com/generalui/github-workflow-accelerators/tree/1.0.0-job-info/.github/actions/job-info) action
    to determine the target environment based on the branch or tag that triggered the workflow.

1) Deploy to Elastic Beanstalk (`deploy`):
    - Depends on the `info` job.
    - Performs several steps to deploy the application to AWS Elastic Beanstalk:
    - __Checkout code__: Checks out the code for the application.
    - __Set up JDK__: Sets up the Java Development Kit (JDK) environment. Uses Corretto 17, matching the Elastic Beanstalk configuration.
    - __Build deployment package__: Builds the application's deployment package (e.g., a JAR file). The environment variables for the database are set using secrets.
    - __Artifact Deploy Package__: (Optional) Saves the deployment package as a GitHub artifact, aiding in debugging and rollback if necessary.
    - __Deploy to Elastic Beanstalk__: Deploys the built package to AWS Elastic Beanstalk using the `beanstalk-deploy` action.

## Inputs

- `terraform-version`: (Optional) Specifies the version of Terraform to use. Defaults to "latest".
- `paths`: (Optional) Specifies newline-separated list of paths to validate. Defaults to the current directory.

## Environment Variables

- `SPRING_DATASOURCE_PASSWORD`: The password for the database.
- `SPRING_DATASOURCE_USERNAME`: The username for the database.
- `SPRING_DATASOURCE_URL`: The JDBC URL for the database.
- `SPRING_LIQUIBASE_URL`: The Liquibase URL for the database.
- `DEPLOY_ENV`: The target environment for deployment.
- `S3_BUCKET`: The name of the S3 bucket for deployment.

## Secrets

- `ACCESS_KEY_ID`: AWS access key ID.
- `SECRET_ACCESS_KEY`: AWS secret access key.

## Usage

To use this workflow:

1) Ensure that the required secrets (`ACCESS_KEY_ID` and `SECRET_ACCESS_KEY`) are set in your repository's secrets.

1) Configure the workflow to match your application's needs, especially the environment variables and the build script.

1) Push code to the `develop` or `main` branches, or manually trigger the workflow.

## Notes

- The workflow is optimized for Java applications but can be adapted for other types of applications.
- Ensure that the AWS credentials provided have the necessary permissions for Elastic Beanstalk operations.
- The deployment package is optionally saved as an artifact on GitHub, providing a backup for rollback if necessary.

---

Remember to replace `your-repo/deploy-to-elastic-beanstalk@v1` with the actual path to your action if you host it in a specific repository.
This README provides a comprehensive guide on how to integrate and leverage the "Deploy to Elastic Beanstalk" action in your GitHub workflows.
