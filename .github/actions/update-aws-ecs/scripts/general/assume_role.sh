#!/bin/bash

# This script is called by the other "general" scripts.
# It shouldn't need to be called on its own.

# To call this script, you MUST pass a role arn and a session name, ie:
# `source ./assume_db_creds_role.sh --roleArn "arn:aws:iam::123456789012:role/db-secret-saccess --sessionName "arn:aws:iam::123456789012:role/db-secret-saccess"`

# Function to handle options and arguments
assume_db_creds_role() {
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
    local session_name=""

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
        echo >&2 -e "${BLUE}Options:${NC}"
        echo >&2 -e "${BLUE} -h, --help          Display this message${NC}"
        echo >&2 -e "${BLUE} -r, --roleArn       The ARN of the role to assume to get DB credentials${NC}"
        echo >&2 -e "${BLUE} -s, --sessionName   The name of the session to create${NC}"
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
        -s | --sessionName)
            if ! has_argument "$@"; then
                echo >&2 -e "${RED}Session name not specified.${NC}"
                usage
                exit 1
            fi
            session_name=$(extract_argument "$@")
            shift
            ;;
        esac
        shift
    done

    if [ "$just_usage" = false ]; then
      # Assume DB Secrets Access role
      local credentials=""
      credentials=$(aws sts assume-role --role-arn "$role_arn" --role-session-name "$session_name")

      if [ -z "$credentials" ]; then
        exit 1
        bash # Start a new bash shell to keep terminal open
      fi

      # Set AWS credential env vars
      AWS_ACCESS_KEY_ID=$(echo "$credentials" | jq -r .Credentials.AccessKeyId)
      AWS_SECRET_ACCESS_KEY=$(echo "$credentials" | jq -r .Credentials.SecretAccessKey)
      AWS_SESSION_TOKEN=$(echo "$credentials" | jq -r .Credentials.SessionToken)
      AWS_DEFAULT_REGION=us-east-2
      export AWS_ACCESS_KEY_ID
      export AWS_SECRET_ACCESS_KEY
      export AWS_SESSION_TOKEN
      export AWS_DEFAULT_REGION
    fi
}

# Main script execution
assume_db_creds_role "$@"
