#!/bin/bash

# This script helps "clean up" the environment variables that are set for the AWS CLI.

unset AWS_SESSION_TOKEN
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
unset AWS_DEFAULT_REGION
