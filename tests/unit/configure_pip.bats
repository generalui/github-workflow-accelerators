#!/usr/bin/env bats
# =============================================================================
# configure_pip.bats
# Unit tests for test-python/scripts/configure_pip.sh
#
# Strategy: replace `pip` and `tput` with lightweight mocks that record
# every call, then assert that configure_pip() invokes pip with the right
# arguments based on which environment variables are set.
# =============================================================================

REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
CONFIGURE_PIP_SCRIPT="$REPO_ROOT/.github/actions/test-python/scripts/configure_pip.sh"

# ---------------------------------------------------------------------------
# Setup / Teardown
# ---------------------------------------------------------------------------

setup() {
  # Create a temp dir for mock binaries
  MOCK_DIR="$(mktemp -d)"
  export MOCK_DIR

  # Mock pip: records args to a log file, exits 0
  cat > "$MOCK_DIR/pip" << 'EOF'
#!/usr/bin/env bash
echo "$@" >> "$MOCK_DIR/pip_calls.log"
exit 0
EOF
  chmod +x "$MOCK_DIR/pip"
  # Inject the MOCK_DIR variable into the mock at runtime
  sed -i.bak 's|\$MOCK_DIR|'"$MOCK_DIR"'|g' "$MOCK_DIR/pip"
  rm -f "$MOCK_DIR/pip.bak"

  # Mock tput: silently succeed (avoids "no terminal" errors in CI)
  cat > "$MOCK_DIR/tput" << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$MOCK_DIR/tput"

  # Prepend mock dir to PATH
  export PATH="$MOCK_DIR:$PATH"

  # Clear all pip-related env vars before each test
  unset GLOBAL_INDEX_URL GLOBAL_TRUSTED_HOST SEARCH_URL

  # Source the script — this defines configure_pip() and immediately calls it
  # with no args (since $@ is empty in the test context). Because all env vars
  # are unset, the initial call is a no-op.
  # shellcheck source=/dev/null
  source "$CONFIGURE_PIP_SCRIPT"

  # Remove any pip calls logged during the initial source-time invocation
  rm -f "$MOCK_DIR/pip_calls.log"
}

teardown() {
  [ -n "${MOCK_DIR:-}" ] && rm -rf "$MOCK_DIR"
  unset GLOBAL_INDEX_URL GLOBAL_TRUSTED_HOST SEARCH_URL
}

# Helper: assert pip was called with a given argument string
assert_pip_called_with() {
  local expected="$1"
  if ! grep -qF "$expected" "$MOCK_DIR/pip_calls.log" 2>/dev/null; then
    echo "FAIL: pip was not called with: $expected" >&2
    echo "Actual pip calls:" >&2
    cat "$MOCK_DIR/pip_calls.log" 2>/dev/null || echo "(no calls)" >&2
    return 1
  fi
}

# Helper: assert pip was never called
assert_pip_not_called() {
  if [[ -f "$MOCK_DIR/pip_calls.log" ]]; then
    echo "FAIL: pip was called but should not have been" >&2
    cat "$MOCK_DIR/pip_calls.log" >&2
    return 1
  fi
}

# ---------------------------------------------------------------------------
# No-op tests (no env vars set)
# ---------------------------------------------------------------------------

@test "configure_pip: does nothing when no env vars are set" {
  configure_pip
  assert_pip_not_called
}

# ---------------------------------------------------------------------------
# GLOBAL_INDEX_URL
# ---------------------------------------------------------------------------

@test "configure_pip: sets global.index-url when GLOBAL_INDEX_URL is set" {
  export GLOBAL_INDEX_URL="https://pypi.example.com/simple"
  configure_pip
  assert_pip_called_with "config set global.index-url https://pypi.example.com/simple"
}

@test "configure_pip: does NOT set global.index-url when GLOBAL_INDEX_URL is empty" {
  export GLOBAL_INDEX_URL=""
  configure_pip
  assert_pip_not_called
}

# ---------------------------------------------------------------------------
# GLOBAL_TRUSTED_HOST
# ---------------------------------------------------------------------------

@test "configure_pip: sets global.trusted-host when GLOBAL_TRUSTED_HOST is set" {
  export GLOBAL_TRUSTED_HOST="pypi.example.com"
  configure_pip
  assert_pip_called_with "config set global.trusted-host pypi.example.com"
}

@test "configure_pip: does NOT set global.trusted-host when GLOBAL_TRUSTED_HOST is empty" {
  export GLOBAL_TRUSTED_HOST=""
  configure_pip
  assert_pip_not_called
}

# ---------------------------------------------------------------------------
# SEARCH_URL
# ---------------------------------------------------------------------------

@test "configure_pip: sets search.index when SEARCH_URL is set" {
  export SEARCH_URL="https://pypi.example.com/pypi"
  configure_pip
  assert_pip_called_with "config set search.index https://pypi.example.com/pypi"
}

@test "configure_pip: does NOT set search.index when SEARCH_URL is empty" {
  export SEARCH_URL=""
  configure_pip
  assert_pip_not_called
}

# ---------------------------------------------------------------------------
# Combined vars
# ---------------------------------------------------------------------------

@test "configure_pip: sets all three when all env vars are provided" {
  export GLOBAL_INDEX_URL="https://pypi.example.com/simple"
  export GLOBAL_TRUSTED_HOST="pypi.example.com"
  export SEARCH_URL="https://pypi.example.com/pypi"

  configure_pip

  assert_pip_called_with "config set global.index-url https://pypi.example.com/simple"
  assert_pip_called_with "config set global.trusted-host pypi.example.com"
  assert_pip_called_with "config set search.index https://pypi.example.com/pypi"
}

@test "configure_pip: sets only the provided vars when only two are given" {
  export GLOBAL_INDEX_URL="https://pypi.example.com/simple"
  export SEARCH_URL="https://pypi.example.com/pypi"
  # GLOBAL_TRUSTED_HOST intentionally NOT set

  configure_pip

  assert_pip_called_with "config set global.index-url https://pypi.example.com/simple"
  assert_pip_called_with "config set search.index https://pypi.example.com/pypi"

  # trusted-host should NOT have been set
  if grep -qF "global.trusted-host" "$MOCK_DIR/pip_calls.log" 2>/dev/null; then
    echo "FAIL: global.trusted-host was set but should not have been" >&2
    return 1
  fi
}

# ---------------------------------------------------------------------------
# --help flag
# ---------------------------------------------------------------------------

@test "configure_pip: --help exits 0 and does not call pip" {
  run bash -c "
    export PATH='$MOCK_DIR:\$PATH'
    export MOCK_DIR='$MOCK_DIR'
    source '$CONFIGURE_PIP_SCRIPT'
    configure_pip --help
  "
  [ "$status" -eq 0 ]
  # pip should not have been called
  [ ! -f "$MOCK_DIR/pip_calls.log" ] || ! grep -q "config set" "$MOCK_DIR/pip_calls.log"
}
