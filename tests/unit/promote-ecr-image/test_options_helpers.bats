#!/usr/bin/env bats
# =============================================================================
# options_helpers.bats
# Unit tests for the options_helpers.sh utility functions.
#
# These helpers are shared across multiple actions:
#   - promote-ecr-image/scripts/general/options_helpers.sh
#   - update-aws-ecs/scripts/general/options_helpers.sh
#   - update-aws-lambda/scripts/general/options_helpers.sh
#
# All three copies are functionally identical; we test one authoritative copy.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../../.." && pwd)"
HELPERS_SCRIPT="$REPO_ROOT/.github/actions/promote-ecr-image/scripts/general/options_helpers.sh"

setup() {
  # shellcheck source=/dev/null
  source "$HELPERS_SCRIPT"
}

# ---------------------------------------------------------------------------
# has_argument
# ---------------------------------------------------------------------------

@test "has_argument: returns true for --flag=value format" {
  has_argument "--flag=value"
}

@test "has_argument: returns true for --flag=value with extra args" {
  has_argument "--flag=value" "--other"
}

@test "has_argument: returns false for --flag= (empty value after =)" {
  ! has_argument "--flag="
}

@test "has_argument: returns true when second arg is a plain value" {
  has_argument "--flag" "myvalue"
}

@test "has_argument: returns false when second arg starts with a dash" {
  ! has_argument "--flag" "--other-flag"
}

@test "has_argument: returns false when no second arg and first has no =" {
  ! has_argument "--flag"
}

@test "has_argument: returns false with only a bare flag and empty second arg" {
  ! has_argument "--flag" ""
}

@test "has_argument: returns true for single-char -r=value" {
  has_argument "-r=arn:aws:iam::123:role/my-role"
}

@test "has_argument: returns true for -r followed by a value" {
  has_argument "-r" "arn:aws:iam::123:role/my-role"
}

# ---------------------------------------------------------------------------
# extract_argument
# ---------------------------------------------------------------------------

@test "extract_argument: extracts value after = in first arg" {
  result=$(extract_argument "--flag=myvalue")
  [ "$result" = "myvalue" ]
}

@test "extract_argument: returns second arg when both formats provided (second wins)" {
  result=$(extract_argument "--flag=fromflag" "fromsecond")
  [ "$result" = "fromsecond" ]
}

@test "extract_argument: returns second arg when only second arg given" {
  result=$(extract_argument "--flag" "onlysecond")
  [ "$result" = "onlysecond" ]
}

@test "extract_argument: handles ARN values with colons and slashes" {
  result=$(extract_argument "--roleArn=arn:aws:iam::123456789012:role/my-role")
  [ "$result" = "arn:aws:iam::123456789012:role/my-role" ]
}

@test "extract_argument: handles ARN value as second argument" {
  result=$(extract_argument "--roleArn" "arn:aws:iam::123456789012:role/my-role")
  [ "$result" = "arn:aws:iam::123456789012:role/my-role" ]
}

@test "extract_argument: handles value with spaces when quoted" {
  result=$(extract_argument "--desc" "a value with spaces")
  [ "$result" = "a value with spaces" ]
}
