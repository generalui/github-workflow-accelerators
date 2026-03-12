#!/usr/bin/env bash
# =============================================================================
# mock_helpers.bash
# Shared helper utilities for bats unit tests.
# Provides mock command creation and assertion utilities.
# =============================================================================

# Set up a temporary directory and create mock executables for the given
# commands. Each mock records every call (arguments) to
# "$MOCK_DIR/<command>_calls.log" and exits 0 by default.
#
# Usage:
#   source tests/helpers/mock_helpers.bash
#   setup_mocks pip tput aws docker
#
# After setup_mocks, $MOCK_DIR is in PATH, so the fakes shadow real binaries.
setup_mocks() {
  MOCK_DIR="$(mktemp -d)"
  export MOCK_DIR

  for cmd in "$@"; do
    # Write the mock script
    cat > "$MOCK_DIR/$cmd" << 'MOCK_SCRIPT'
#!/usr/bin/env bash
# Record the call
echo "$@" >> "${MOCK_DIR}/${0##*/}_calls.log"
exit 0
MOCK_SCRIPT

    # Substitute the actual command name (heredoc can't expand $cmd)
    sed -i.bak "s|\${0##\*/}|${cmd}|g" "$MOCK_DIR/$cmd"
    rm -f "$MOCK_DIR/$cmd.bak"
    chmod +x "$MOCK_DIR/$cmd"
  done

  # Prepend mock dir to PATH so mocks shadow real binaries
  export PATH="$MOCK_DIR:$PATH"
}

# Remove the mock directory created by setup_mocks.
teardown_mocks() {
  if [[ -n "${MOCK_DIR:-}" && -d "$MOCK_DIR" ]]; then
    rm -rf "$MOCK_DIR"
  fi
}

# Assert that a mock was called with the given argument string.
#
# Usage:
#   assert_mock_called_with "pip" "config set global.index-url https://example.com"
assert_mock_called_with() {
  local cmd="$1"
  local expected_args="$2"
  local log_file="$MOCK_DIR/${cmd}_calls.log"

  if [[ ! -f "$log_file" ]]; then
    echo "FAIL: mock '$cmd' was never called (no call log found)" >&2
    return 1
  fi

  if ! grep -qF "$expected_args" "$log_file"; then
    echo "FAIL: mock '$cmd' was not called with args: $expected_args" >&2
    echo "Actual calls recorded in $log_file:" >&2
    cat "$log_file" >&2
    return 1
  fi

  return 0
}

# Assert that a mock was NOT called at all.
#
# Usage:
#   assert_mock_not_called "pip"
assert_mock_not_called() {
  local cmd="$1"
  local log_file="$MOCK_DIR/${cmd}_calls.log"

  if [[ -f "$log_file" ]]; then
    echo "FAIL: mock '$cmd' was called but should not have been" >&2
    echo "Calls recorded:" >&2
    cat "$log_file" >&2
    return 1
  fi

  return 0
}

# Return the call count for a given mock command.
mock_call_count() {
  local cmd="$1"
  local log_file="$MOCK_DIR/${cmd}_calls.log"
  if [[ -f "$log_file" ]]; then
    wc -l < "$log_file" | tr -d ' '
  else
    echo "0"
  fi
}
