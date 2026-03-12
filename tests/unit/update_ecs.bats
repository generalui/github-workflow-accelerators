#!/usr/bin/env bats
# =============================================================================
# update_ecs.bats
# Unit tests for update-aws-ecs/scripts/update_ecs.sh
#
# Tests cover:
#   - --help flag (exits 0, no AWS calls)
#   - AWS CLI invocation with correct arguments (using a mock aws binary)
#   - Failure when aws ecs update-service returns empty response
#
# Strategy: setup() prepends a MOCK_DIR to PATH and exports it. All run
# bash -c "..." subshells inherit this PATH automatically — do NOT override
# PATH inside the subshell, as that breaks system tools like dirname.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
UPDATE_ECS_SCRIPT="$REPO_ROOT/.github/actions/update-aws-ecs/scripts/update_ecs.sh"

setup() {
  MOCK_DIR="$(mktemp -d)"
  export MOCK_DIR

  # Mock aws: records all calls; returns real-looking JSON for known sub-commands
  cat > "$MOCK_DIR/aws" << MOCK
#!/bin/bash
echo "\$@" >> "${MOCK_DIR}/aws_calls.log"
if [[ "\$*" == *"assume-role"* ]]; then
  echo '{"Credentials":{"AccessKeyId":"FAKEKEY","SecretAccessKey":"FAKESECRET","SessionToken":"FAKETOKEN","Expiration":"2099-01-01T00:00:00Z"}}'
elif [[ "\$*" == *"update-service"* ]]; then
  echo '{"service":{"serviceName":"test-service","clusterArn":"arn:aws:ecs:us-east-1:123:cluster/test"}}'
fi
exit 0
MOCK
  chmod +x "$MOCK_DIR/aws"

  # Mock tput (avoids "no terminal" errors in CI)
  printf '#!/bin/sh\nexit 0\n' > "$MOCK_DIR/tput"
  chmod +x "$MOCK_DIR/tput"

  # Prepend mock dir — subshells inherit this PATH
  export PATH="$MOCK_DIR:$PATH"

  # Required env vars (used by the script's function body)
  export CLUSTER_NAME="my-cluster"
  export SERVICE_NAME="my-service"
  export ASSUME_ECS_ACCESS_ROLE_ARN="arn:aws:iam::123456789012:role/ecs-access"
  export AWS_DEFAULT_REGION="us-east-1"
}

teardown() {
  [ -n "${MOCK_DIR:-}" ] && rm -rf "$MOCK_DIR"
  unset CLUSTER_NAME SERVICE_NAME ASSUME_ECS_ACCESS_ROLE_ARN AWS_DEFAULT_REGION
}

# ---------------------------------------------------------------------------
# --help flag
# ---------------------------------------------------------------------------

@test "update_ecs: --help exits 0 without running the main body" {
  # Pass --help as positional arg via set -- so update_ecs "$@" receives it
  run bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    set -- --help
    source '$UPDATE_ECS_SCRIPT'
  "
  [ "$status" -eq 0 ]
}

@test "update_ecs: --help does not call aws ecs update-service" {
  run bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    set -- --help
    source '$UPDATE_ECS_SCRIPT'
  "
  [ ! -f "$MOCK_DIR/aws_calls.log" ] || ! grep -q "update-service" "$MOCK_DIR/aws_calls.log"
}

# ---------------------------------------------------------------------------
# Successful execution
# ---------------------------------------------------------------------------

@test "update_ecs: calls aws ecs update-service" {
  bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  grep -q "update-service" "$MOCK_DIR/aws_calls.log"
}

@test "update_ecs: passes --force-new-deployment to aws ecs update-service" {
  bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  grep -q "force-new-deployment" "$MOCK_DIR/aws_calls.log"
}

@test "update_ecs: passes CLUSTER_NAME to aws ecs update-service" {
  bash -c "
    export CLUSTER_NAME='production-cluster'
    export SERVICE_NAME='api-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  grep -q "production-cluster" "$MOCK_DIR/aws_calls.log"
}

@test "update_ecs: passes SERVICE_NAME to aws ecs update-service" {
  bash -c "
    export CLUSTER_NAME='production-cluster'
    export SERVICE_NAME='api-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  grep -q "api-service" "$MOCK_DIR/aws_calls.log"
}

@test "update_ecs: calls aws sts assume-role before update-service" {
  bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  grep -q "assume-role" "$MOCK_DIR/aws_calls.log"
}

# ---------------------------------------------------------------------------
# Failure: empty response from aws ecs update-service
# ---------------------------------------------------------------------------

@test "update_ecs: exits 1 when aws ecs update-service returns empty response" {
  # Override mock to return empty for update-service
  cat > "$MOCK_DIR/aws" << MOCK
#!/bin/bash
echo "\$@" >> "${MOCK_DIR}/aws_calls.log"
if [[ "\$*" == *"assume-role"* ]]; then
  echo '{"Credentials":{"AccessKeyId":"KEY","SecretAccessKey":"SECRET","SessionToken":"TOKEN","Expiration":"2099-01-01T00:00:00Z"}}'
fi
# Intentionally return nothing for update-service
exit 0
MOCK
  chmod +x "$MOCK_DIR/aws"

  run bash -c "
    export CLUSTER_NAME='my-cluster'
    export SERVICE_NAME='my-service'
    export ASSUME_ECS_ACCESS_ROLE_ARN='arn:aws:iam::123:role/ecs-access'
    export AWS_DEFAULT_REGION='us-east-1'
    source '$UPDATE_ECS_SCRIPT'
  "
  [ "$status" -eq 1 ]
}
