#!/usr/bin/env bats
# =============================================================================
# promote_image.bats
# Unit tests for promote-ecr-image/scripts/promote_image.sh
#
# Strategy: test the env var validation logic and --help behaviour.
# The core AWS+Docker operations require live credentials and are integration
# tests; those are NOT covered here.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
PROMOTE_IMAGE_SCRIPT="$REPO_ROOT/.github/actions/promote-ecr-image/scripts/promote_image.sh"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# All required env vars for the promote_image function
_set_all_required_vars() {
  export AWS_ACCOUNT="123456789012"
  export AWS_DEFAULT_REGION="us-east-1"
  export ENVIRONMENT="staging"
  export ECR="my-ecr-repo"
  export ECR_ACCESS_ROLE_NAME="ecr-write-access"
  export ECR_TAG_NAME="my-app"
  export LOWER_AWS_ACCOUNT="098765432109"
  export LOWER_AWS_DEFAULT_REGION="us-east-1"
  export LOWER_BRANCH="dev"
  export LOWER_ECR="my-ecr-repo"
  export LOWER_ECR_ACCESS_ROLE_NAME="ecr-write-access"
}

_unset_all_required_vars() {
  unset AWS_ACCOUNT AWS_DEFAULT_REGION ENVIRONMENT ECR ECR_ACCESS_ROLE_NAME \
        ECR_TAG_NAME LOWER_AWS_ACCOUNT LOWER_AWS_DEFAULT_REGION LOWER_BRANCH \
        LOWER_ECR LOWER_ECR_ACCESS_ROLE_NAME
}

setup() {
  _unset_all_required_vars
}

teardown() {
  _unset_all_required_vars
}

# ---------------------------------------------------------------------------
# Required environment variable validation
# ---------------------------------------------------------------------------

@test "promote_image: exits 1 when AWS_ACCOUNT is missing" {
  run bash -c "
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when AWS_DEFAULT_REGION is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when ENVIRONMENT is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when ECR is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when ECR_ACCESS_ROLE_NAME is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when ECR_TAG_NAME is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when LOWER_AWS_ACCOUNT is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when LOWER_BRANCH is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when LOWER_ECR is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when LOWER_ECR_ACCESS_ROLE_NAME is missing" {
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 1 ]
}

@test "promote_image: exits 1 when no env vars are set" {
  run bash -c "source '$PROMOTE_IMAGE_SCRIPT'"
  [ "$status" -eq 1 ]
}

@test "promote_image: error output mentions the missing variable name" {
  run bash -c "source '$PROMOTE_IMAGE_SCRIPT'" 2>&1
  # At minimum one of the required var names should appear in stderr
  [[ "$output" =~ "AWS_ACCOUNT" ]] || [[ "$output" =~ "are empty" ]]
}

# ---------------------------------------------------------------------------
# --help flag
# ---------------------------------------------------------------------------

@test "promote_image: --help exits 0" {
  # Pass --help via set -- so the script's bottom-level `promote_image "$@"` call
  # receives it. All required env vars are set so the validation block passes first.
  run bash -c "
    export AWS_ACCOUNT='123456789012'
    export AWS_DEFAULT_REGION='us-east-1'
    export ENVIRONMENT='staging'
    export ECR='my-ecr-repo'
    export ECR_ACCESS_ROLE_NAME='ecr-write-access'
    export ECR_TAG_NAME='my-app'
    export LOWER_AWS_ACCOUNT='098765432109'
    export LOWER_AWS_DEFAULT_REGION='us-east-1'
    export LOWER_BRANCH='dev'
    export LOWER_ECR='my-ecr-repo'
    export LOWER_ECR_ACCESS_ROLE_NAME='ecr-write-access'
    set -- --help
    source '$PROMOTE_IMAGE_SCRIPT'
  "
  [ "$status" -eq 0 ]
}
