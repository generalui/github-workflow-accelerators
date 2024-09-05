#!/bin/bash

# To call this script, you MUST pass a role arn, ie:
# `source ./assume_lambda_update_role.sh --roleArn "arn:aws:iam::123456789012:role/lambda-update"`

# Function to handle options and arguments
assume_lambda_update_role() {
    # Defined some useful colors for echo outputs.
    # Use BLUE for informational.
    local BLUE="\033[1;34m"
    # Use RED for error informational and extreme actions.
    local RED="\033[1;31m"
    # No Color (used to stop or reset a color).
    local NC='\033[0m'

    local just_usage=false

    # Initialize variable to store the flag value
    local role_arn=""

    # Get the absolute path of the current script
    local SCRIPT_PATH=""
    SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "$SCRIPT_PATH"/options_helpers.sh

    # Function to display script usage
    usage() {
        just_usage=true
        echo >&2 -e "${BLUE}Running this script will assume the role associated with the passed role ARN.${NC}"
        echo >&2 -e "${BLUE}It will export the returned credentials as environment variables.${NC}"
        echo >&2 -e "${BLUE}This script requires jq to be installed on the system.${NC}"
        echo ""
        echo >&2 -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
        echo ""
        echo >&2 -e "${BLUE} -h, --help          Display this message${NC}"
        echo >&2 -e "${BLUE} -r, --roleArn       The ARN of the role to assume to get Lambda update permissions${NC}"
    }

    while [ $# -gt 0 ]; do
        case $1 in
        -h | --help)
            usage
            ;;
        -r | --roleArn)
            if ! has_argument "$@"; then
                echo >&2 -e "${RED}Role ARN not specified.${NC}"
                usage
                exit 1
            fi
            role_arn=$(extract_argument "$@")
            shift
            ;;
        esac
        shift
    done

    if [ "$just_usage" = false ]; then
        # Assume the Lambda update role and export the credentials as env vars.
        source "$SCRIPT_PATH"/assume_role.sh --roleArn "$role_arn" --sessionName "lambda-update"
    fi
}

# Main script execution
assume_lambda_update_role "$@"
