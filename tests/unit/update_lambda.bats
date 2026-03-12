#!/usr/bin/env bats
# =============================================================================
# update_lambda.bats
# Unit tests for update-aws-lambda/scripts/update_lambda.sh
#
# Tests cover:
#   - --help flag (exits 0, no AWS calls)
#   - AWS CLI invocation with correct arguments (using a mock aws binary)
#   - Failure when aws lambda update-function-code returns empty response
#
# Strategy: setup() prepends a MOCK_DIR to PATH and exports it. All run
# bash -c "..." subshells inherit this PATH automatically — do NOT override
# PATH inside the subshell, as that breaks system tools like dirname.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
UPDATE_LAMBDA_SCRIPT="$REPO_ROOT/.github/actions/update-aws-lambda/scripts/update_lambda.sh"

setup() {
  MOCK_DIR="$(mktemp -d)"
  export MOCK_DIR

  # Mock aws: records all calls; returns real-looking JSON for known sub-commands
  cat > "$MOCK_DIR/aws" << MOCK
#!/bin/bash
echo "\$@" >> "${MOCK_DIR}/aws_calls.log"
if [[ "\$*" == *"assume-role"* ]]; then
  echo '{"Credentials":{"AccessKeyId":"FAKEKEY","SecretAccessKey":"FAKESECRET","SessionToken":"FAKETOKEN","Expiration":"2099-01-01T00:00:00Z"}}'
elif [[ "\$*" == *"update-function-code"* ]]; then
  echo '{"FunctionName":"my-function","FunctionArn":"arn:aws:lambda:us-east-1:123:function:my-function"}'
fi
exit 0
MOCK
  chmod +x "$MOCK_DIR/aws"

  # Mock tput (avoids "no terminal" errors in CI)
  printf '#!/bin/sh\nexit 0\n' > "$MOCK_DIR/tput"
  chmod +x "$MOCK_DIR/tput"

  # Prepend mock dir — subshells inherit this PATH
  export PATH="$MOCK_DIR:$PATH"

  # Required env vars
  export FUNCTION_NAME="my-lambda-function"
  export IMAGE_URL="123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:prod-latest"
  export ASSUME_LAMBDA_UPDATE_ROLE_ARN="arn:aws:iam::123456789012:role/lambda-update"
  export AWS_DEFAULT_REGION="us-east-1"
}

teardown() {
  [ -n "${MOCK_DIR:-}" ] && rm -rf "$MOCK_DIR"
  unset FUNCTION_NAME IMAGE_URL ASSUME_LAMBDA_UPDATE_ROLE_ARN AWS_DEFAULT_REGION
}

# ---------------------------------------------------------------------------
# --help flag
# ---------------------------------------------------------------------------

@test "update_lambda: --help exits 0 without running the main body" {
  # Pass --help as positional arg via set -- so update_lambda "$@" receives it
  run bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:tag'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    set -- --help
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  [ "$status" -eq 0 ]
}

@test "update_lambda: --help does not call aws lambda update-function-code" {
  run bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:tag'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    set -- --help
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  [ ! -f "$MOCK_DIR/aws_calls.log" ] || ! grep -q "update-function-code" "$MOCK_DIR/aws_calls.log"
}

# ---------------------------------------------------------------------------
# Successful execution
# ---------------------------------------------------------------------------

@test "update_lambda: calls aws lambda update-function-code" {
  bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:prod-latest'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  grep -q "update-function-code" "$MOCK_DIR/aws_calls.log"
}

@test "update_lambda: passes FUNCTION_NAME to aws lambda update-function-code" {
  bash -c "
    export FUNCTION_NAME='payments-processor'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:prod-latest'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  grep -q "payments-processor" "$MOCK_DIR/aws_calls.log"
}

@test "update_lambda: passes IMAGE_URL to aws lambda update-function-code" {
  bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/payments:prod-20240101000000'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  grep -q "prod-20240101000000" "$MOCK_DIR/aws_calls.log"
}

@test "update_lambda: calls aws sts assume-role before update-function-code" {
  bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:prod-latest'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  grep -q "assume-role" "$MOCK_DIR/aws_calls.log"
}

# ---------------------------------------------------------------------------
# Failure: empty response from aws lambda update-function-code
# ---------------------------------------------------------------------------

@test "update_lambda: exits 1 when aws lambda update-function-code returns empty response" {
  # Override mock to return empty for update-function-code
  cat > "$MOCK_DIR/aws" << MOCK
#!/bin/bash
echo "\$@" >> "${MOCK_DIR}/aws_calls.log"
if [[ "\$*" == *"assume-role"* ]]; then
  echo '{"Credentials":{"AccessKeyId":"KEY","SecretAccessKey":"SECRET","SessionToken":"TOKEN","Expiration":"2099-01-01T00:00:00Z"}}'
fi
# Intentionally return nothing for update-function-code
exit 0
MOCK
  chmod +x "$MOCK_DIR/aws"

  run bash -c "
    export FUNCTION_NAME='my-function'
    export IMAGE_URL='123.dkr.ecr.us-east-1.amazonaws.com/repo:prod-latest'
    export ASSUME_LAMBDA_UPDATE_ROLE_ARN='arn:aws:iam::123:role/lambda-update'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_LAMBDA_SCRIPT'
  "
  [ "$status" -eq 1 ]
}
