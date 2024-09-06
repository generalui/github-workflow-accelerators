#!/bin/bash

# To call this script, you MUST pass a role arn, ie:
# `source ./assume_ecr_write_access_role.sh --roleArn "arn:aws:iam::123456789012:role/ecr-write-access"`

# Function to handle options and arguments
assume_ecr_write_access_role() {
    # Defined some useful colors for echo outputs.
    # Use blue for informational.
    local blue="\033[1;34m"
    # Use red for error informational and extreme actions.
    local red="\033[1;31m"
    # No Color (used to stop or reset a color).
    local nc='\033[0m'

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
        echo >&2 -e "${blue}Running this script will assume the role associated with the passed role ARN.${nc}"
        echo >&2 -e "${blue}It will export the returned credentials as environment variables.${nc}"
        echo >&2 -e "${blue}This script requires jq to be installed on the system.${nc}"
        echo ""
        echo >&2 -e "${blue}Usage: $0 [OPTIONS]${nc}"
        echo ""
        echo >&2 -e "${blue} -h, --help          Display this message${nc}"
        echo >&2 -e "${blue} -r, --roleArn       The ARN of the role to assume to get ECR write access${nc}"
    }

    while [ $# -gt 0 ]; do
        case $1 in
        -h | --help)
            usage
            ;;
        -r | --roleArn)
            if ! has_argument "$@"; then
                echo >&2 -e "${red}Role ARN not specified.${nc}"
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
        # Assume the ECR write access role and export the credentials as env vars.
        source "$SCRIPT_PATH"/assume_role.sh --roleArn "$role_arn" --sessionName "ecr-write-access"
    fi
}

# Main script execution
assume_ecr_write_access_role "$@"
