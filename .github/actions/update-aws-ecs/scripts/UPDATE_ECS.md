# Update ECS

The [`update_ecs.sh`](./update_ecs.sh) script will force update the passed ECS service.

## AWS Permissions

Gain permissions to write to update the passed ECS service via the appropriate ECS access AWS IAM group.
(ie "eo-dev-lecole-app-ecs-access")

## Using the Scripts

Any user may update the ECS service.
The user MUST have AWS credentials set up (`~/.aws/credentials`) and be a member of the appropriate ECS access AWS IAM group.
(ie "eo-dev-lecole-app-ecs-access")

## Script Help

The script will display a little help message if it is passed the "help" flag:

`./update_ecs.sh --help`
