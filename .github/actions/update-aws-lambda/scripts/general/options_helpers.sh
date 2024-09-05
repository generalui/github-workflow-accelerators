#!/bin/bash

# These functions are used commonly by other scripts in "general".

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || (-n "$2" && "$2" != -*) ]]
}

extract_argument() {
    echo "${2:-${1#*=}}"
}
