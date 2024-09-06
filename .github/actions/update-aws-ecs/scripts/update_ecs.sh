#!/bin/bash

# To run this script, the configured AWS user MUST have credentials configured
# in credentials files (see: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
# The configured user MUST me in the appropriate ECS access IAM group (ie "eo-dev-lecole-app-ecs-access").
# This script may need a few environment variables set.
# Ensure `CLUSTER_NAME`, `SERVICE_NAME`, and `ECS_ACCESS_ROLE_NAME` are correct.

update_ecs() {
    # Defined some useful colors for echo outputs.
    # Use blue for informational.
    local blue="\033[1;34m"
    # Use green for success informational.
    local green="\033[1;32m"
    # Use red for error informational and extreme actions.
    local red="\033[1;31m"
    # No Color (used to stop or reset a color).
    local nc='\033[0m'

    local usage_only=false

    local cluster=${CLUSTER_NAME}
    local service=${SERVICE_NAME}
    local role_arn=${ASSUME_ECS_ACCESS_ROLE_ARN}

    # Get the absolute path of the current script
    local script_path=""
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${script_path}"/general/options_helpers.sh

    # Function to display script usage
    usage() {
        usage_only=true
        echo >&2 -e "${blue}Running this script will force update the passed ECS service.${nc}"
        echo >&2 -e "${blue}This script may need a few environment variables set.${nc}"
        echo >&2 -e "${blue}Ensure ${nc}CLUSTER_NAME${blue}, ${nc}SERVICE_NAME${blue}, and ${nc}ECS_ACCESS_ROLE_NAME${blue} are correct.${nc}"
        echo ""
        echo >&2 -e "${blue}Usage: $0 [OPTIONS]${nc}"
        echo ""
        echo >&2 -e "${blue}Options:${nc}"
        echo >&2 -e "${blue} -h, --help          Display this message${nc}"
    }

    # Handle options and arguments
    while [ $# -gt 0 ]; do
        case $1 in
        -h | --help)
            usage
            ;;
        esac
        shift
    done

    if [ "$usage_only" = false ]; then
        # Start clean
        source "${script_path}"/general/aws_unset.sh

        # Assume the ECS access role
        source "${script_path}"/general/assume_ecs_access_role.sh --roleArn "${role_arn}"

        echo >&2 -e "${blue}Force updating the ${service} service in the ${cluster} ECS cluster.${nc}"

        # Force update the ECS service
        local response=""
        response=$(aws ecs update-service --cluster "${cluster}" --service "${service}" --force-new-deployment --region "$AWS_DEFAULT_REGION")

        echo >&2 -e "${green}response: ${response}${nc}"

        if [ -z "$response" ]; then
            echo >&2 -e "${red}ECS update failed.${nc}"
            exit 1
            bash # Start a new bash shell to keep terminal open
        fi

        # Clean up
        source "${script_path}"/general/aws_unset.sh
    fi
}

# Main script execution
update_ecs "$@"
