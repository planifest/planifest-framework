#!/usr/bin/env bash
# Test runner for context-mode-hooks
# Usage: bash src/context-mode-hooks/tests/run-tests.sh
# Run from the project root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "context-mode-hooks — test suite"
echo "================================"
echo ""

TOTAL_PASS=0
TOTAL_FAIL=0

run_test_file() {
  local test_file="$1"
  local name
  name="$(basename "$test_file")"

  echo "--- $name ---"
  if bash "$test_file"; then
    ((TOTAL_PASS++)) || true
  else
    ((TOTAL_FAIL++)) || true
  fi
  echo ""
}

run_test_file "$SCRIPT_DIR/test-block-grep.sh"
run_test_file "$SCRIPT_DIR/test-block-bash.sh"
run_test_file "$SCRIPT_DIR/test-block-webfetch.sh"

echo "================================"
if [ "$TOTAL_FAIL" -eq 0 ]; then
  echo "All $((TOTAL_PASS)) test files passed."
  exit 0
else
  echo "$TOTAL_FAIL test file(s) failed, $TOTAL_PASS passed."
  exit 1
fi
