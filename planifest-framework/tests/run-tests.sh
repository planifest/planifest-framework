#!/usr/bin/env bash
# Test runner for planifest-framework tests
# Usage: bash planifest-framework/tests/run-tests.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0

run_suite() {
  local file="$1"
  local name
  name="$(basename "$file")"
  echo ""
  echo "--- $name ---"
  if bash "$file"; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  fi
}

run_suite "$SCRIPT_DIR/test-setup-telemetry.sh"
run_suite "$SCRIPT_DIR/test-context-pressure.sh"
run_suite "$SCRIPT_DIR/test-skill-telemetry.sh"
run_suite "$SCRIPT_DIR/test-regression-pack.sh"
run_suite "$SCRIPT_DIR/test-0000005-framework-governance.sh"
run_suite "$SCRIPT_DIR/test-0000006-build-assessment.sh"

# ── Regression Suite ──────────────────────────────────────────────────────────

REGRESSION_PASS=0
REGRESSION_FAIL=0

echo ""
echo "=== Regression Suite ==="

REGRESSION_DIR="$SCRIPT_DIR/regression"
REGRESSION_TESTS=("$REGRESSION_DIR"/test-*.sh)

if [ ! -e "${REGRESSION_TESTS[0]}" ]; then
  echo "  No regression tests yet."
else
  for regression_test in "${REGRESSION_TESTS[@]}"; do
    name="$(basename "$regression_test")"
    echo ""
    echo "--- $name ---"
    if bash "$regression_test"; then
      REGRESSION_PASS=$((REGRESSION_PASS + 1))
    else
      REGRESSION_FAIL=$((REGRESSION_FAIL + 1))
    fi
  done
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "================================"
echo "Feature suites:    $TOTAL_PASS passed, $TOTAL_FAIL failed."
echo "Regression suite:  $REGRESSION_PASS passed, $REGRESSION_FAIL failed."
echo "================================"

if [ "$TOTAL_FAIL" -eq 0 ] && [ "$REGRESSION_FAIL" -eq 0 ]; then
  echo "All tests passed."
  exit 0
else
  echo "One or more tests failed."
  exit 1
fi
