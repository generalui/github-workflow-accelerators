#!/usr/bin/env bats
# =============================================================================
# aws_unset.bats
# Unit tests for the aws_unset.sh helper script.
#
# This script is duplicated across three actions — all copies are identical.
# We test the promote-ecr-image version as the canonical copy.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
AWS_UNSET_SCRIPT="$REPO_ROOT/.github/actions/promote-ecr-image/scripts/general/aws_unset.sh"

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

@test "aws_unset: unsets AWS_ACCESS_KEY_ID" {
  export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"
  [ -z "${AWS_ACCESS_KEY_ID:-}" ]
}

@test "aws_unset: unsets AWS_SECRET_ACCESS_KEY" {
  export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"
  [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]
}

@test "aws_unset: unsets AWS_SESSION_TOKEN" {
  export AWS_SESSION_TOKEN="AQoDYXdzEJr//example//session//token"
  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"
  [ -z "${AWS_SESSION_TOKEN:-}" ]
}

@test "aws_unset: unsets AWS_DEFAULT_REGION" {
  export AWS_DEFAULT_REGION="us-east-1"
  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"
  [ -z "${AWS_DEFAULT_REGION:-}" ]
}

@test "aws_unset: is a no-op when vars are already unset" {
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION
  # Should not error
  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"
  [ -z "${AWS_ACCESS_KEY_ID:-}" ]
  [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]
  [ -z "${AWS_SESSION_TOKEN:-}" ]
  [ -z "${AWS_DEFAULT_REGION:-}" ]
}

@test "aws_unset: clears all four vars in one pass" {
  export AWS_ACCESS_KEY_ID="key"
  export AWS_SECRET_ACCESS_KEY="secret"
  export AWS_SESSION_TOKEN="token"
  export AWS_DEFAULT_REGION="eu-west-1"

  # shellcheck source=/dev/null
  source "$AWS_UNSET_SCRIPT"

  [ -z "${AWS_ACCESS_KEY_ID:-}" ]
  [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]
  [ -z "${AWS_SESSION_TOKEN:-}" ]
  [ -z "${AWS_DEFAULT_REGION:-}" ]
}

@test "aws_unset: identical copies across actions produce the same result" {
  # Verify all three copies of aws_unset.sh produce equivalent results.
  local scripts=(
    "$REPO_ROOT/.github/actions/promote-ecr-image/scripts/general/aws_unset.sh"
    "$REPO_ROOT/.github/actions/update-aws-ecs/scripts/general/aws_unset.sh"
    "$REPO_ROOT/.github/actions/update-aws-lambda/scripts/general/aws_unset.sh"
  )

  for script in "${scripts[@]}"; do
    export AWS_ACCESS_KEY_ID="key"
    export AWS_SESSION_TOKEN="token"
    # shellcheck source=/dev/null
    source "$script"
    [ -z "${AWS_ACCESS_KEY_ID:-}" ]
    [ -z "${AWS_SESSION_TOKEN:-}" ]
  done
}
