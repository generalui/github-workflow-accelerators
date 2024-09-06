# Update Lambda

The [`update_lambda.sh`](./update_lambda.sh) script will force update the passed Lambda.

## AWS Permissions

Gain permissions to write to update the passed Lambda via the appropriate Lambda update AWS IAM group.
(ie "eo-dev-intake-pipeline-intake-lambda-access")

## Using the Scripts

Any user may update the Lambda image.
The user MUST have AWS credentials set up (`~/.aws/credentials`) and be a member of the appropriate Lambda update AWS IAM group.
(ie "eo-dev-intake-pipeline-intake-lambda-access")

## Script Help

Calling this script with the "help" argument will display the usage, but will NOT execute the script:

```sh
./update_lambda.sh --help
```

or

```sh
./update_lambda.sh -h
```
