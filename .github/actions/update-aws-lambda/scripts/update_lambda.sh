#!/bin/bash

# To run this script, the configured AWS user MUST have credentials configured
# in credentials files (see: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
# The configured user MUST me in the appropriate Lambda update IAM group (ie "eo-dev-lecole-lambda-update").
# This script may need a few environment variables set.
# Ensure `FUNCTION_NAME`, `IMAGE_URL`, and `ASSUME_LAMBDA_UPDATE_ROLE_ARN` have the correct values.
# Calling this script with the "help" argument will display the usage, but will NOT execute the script.
# `./update_lambda.sh --help` or `./update_lambda.sh -h`

function update_lambda() {
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

    local function_name="${FUNCTION_NAME}"
    local image_uri="${IMAGE_URL}"
    local role_arn=${ASSUME_LAMBDA_UPDATE_ROLE_ARN}

    # Get the absolute path of the current script
    local script_path=""
    script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Function to display script usage
    usage() {
        usage_only=true
        echo >&2 -e "${blue}Running this script will update the passed lambda function with the passed image code.${nc}"
        echo >&2 -e "${blue}This script needs a few environment variables set.${nc}"
        echo >&2 -e "${blue}Ensure ${nc}FUNCTION_NAME${blue}, ${nc}IMAGE_URL${blue}, and ${nc}ASSUME_LAMBDA_UPDATE_ROLE_ARN${blue} have the correct values.${nc}"
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
            exit 0
            ;;
        esac
        shift
    done

    if [ "$usage_only" = false ]; then
        # Start clean
        source "${script_path}"/general/aws_unset.sh

        # Assume the Lambda update role
        source "${script_path}"/general/assume_lambda_update_role.sh --roleArn "${role_arn}"

        echo >&2 -e "${blue}Updating the ${function_name} lambda with the ${image_uri} image.${nc}"

        local response=""
        response=$(aws lambda update-function-code --function-name "${function_name}" --image-uri "${image_uri}")

        if [ -z "$response" ]; then
            echo >&2 -e "${red}Lambda function update failed.${nc}"
            exit 1
        fi

        echo >&2 -e "${green}response: ${response}${nc}"

        # Clean up
        source "${script_path}"/general/aws_unset.sh
    fi
}

update_lambda "$@"
