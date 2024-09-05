#!/bin/bash

# This script will update the global index-url and trusted-host as well as the search index in the pip configuration.
# Values may be set for the following environment variables: GLOBAL_INDEX_URL, GLOBAL_TRUSTED_HOST, and SEARCH_URL

configure_pip() {
    # Defined some useful colors for echo outputs.
    # Use blue for informational.
    local blue="\033[1;34m"
    # Use cyan for informational headlines.
    local cyan="\033[1;36m"
    # No Color (used to stop or reset a color).
    local nc='\033[0m'
    # And some styles.
    local bold=""
    bold=$(tput bold)
    local normal=""
    normal=$(tput sgr0)

    local usage_only=false

    local global_index_url="${GLOBAL_INDEX_URL}"
    local global_trusted_host="${GLOBAL_TRUSTED_HOST}"
    local search_url="${SEARCH_URL}"

    # Function to display script usage
    usage() {
        usage_only=true
        echo >&2 -e "${cyan}Running this script will update the global index-url and trusted-host as well as the search index in the pip config.${nc}"
        echo ""
        echo >&2 -e "${bold}${cyan}Usage: $0 [OPTIONS]${nc}${normal}"
        echo ""
        echo >&2 -e "${bold}${cyan}Options:${nc}"
        echo >&2 -e "${blue} -h, --help     Display this message${nc}${normal}"
        echo ""
        echo >&2 -e "${blue}Values may be set for the following environment variables:${nc}"
        echo >&2 -e "${cyan}GLOBAL_INDEX_URL${nc}${blue}: current value == ${cyan}${global_index_url:-(No value set)}${nc}"
        echo >&2 -e "   ${blue}The base URL of the Python Package Index (default https://pypi.org/simple). This should point to a repository compliant with PEP 503 (the simple repository API) or a local directory laid out in the same format. If none is passed, the index URL will not be updated.${nc}"
        echo >&2 -e "${cyan}GLOBAL_TRUSTED_HOST${nc}${blue}: current value == ${cyan}${global_trusted_host:-(No value set)}${nc}"
        echo >&2 -e "   ${blue}The host of the global trusted host to use for PIP. This will mark this host or host:port pair as trusted, even though it does not have valid or any HTTPS. If none is passed, the trusted host will not be updated.${nc}"
        echo >&2 -e "${cyan}SEARCH_URL${nc}${blue}: current value == ${cyan}${search_url:-(No value set)}${nc}"
        echo >&2 -e "   ${blue}The search index to use for PIP. Base URL of Python Package Index (default https://pypi.org/pypi). If none is passed, the search index will not be updated.${nc}"
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
        if [ -n "${global_index_url}" ]; then
            echo >&2 -e "${blue}Updating global.index-url: ${global_index_url}.${nc}"
            pip config set global.index-url "${global_index_url}"
        fi
        if [ -n "${global_trusted_host}" ]; then
            echo >&2 -e "${blue}Updating global.trusted-host: ${global_trusted_host}.${nc}"
            pip config set global.trusted-host "${global_trusted_host}"
        fi
        if [ -n "${search_url}" ]; then
            echo >&2 -e "${blue}Updating search.index: ${search_url}.${nc}"
            pip config set search.index "${search_url}"
        fi
    fi
}

configure_pip "$@"
