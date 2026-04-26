#!/usr/bin/env bash
# Tests for regression-pack infrastructure (req-014)
# Covers: promote-to-regression.sh, regression-manifest.json, run-tests.sh regression block

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers/assert.sh"

PROMOTE="$SCRIPT_DIR/../scripts/promote-to-regression.sh"
REAL_REGRESSION_DIR="$SCRIPT_DIR/regression"
REAL_MANIFEST="$REAL_REGRESSION_DIR/regression-manifest.json"
TMPDIR_BASE="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_BASE"' EXIT

# ── Test environment setup ────────────────────────────────────────────────────

make_env() {
  local dir="$1"
  mkdir -p "$dir/tests/regression"
  mkdir -p "$dir/scripts"
  # Seed an empty manifest
  printf '{"tests":[]}\n' > "$dir/tests/regression/regression-manifest.json"
  # Copy the promotion script, pointing it at our temp dirs
  cp "$PROMOTE" "$dir/scripts/promote-to-regression.sh"
  # Patch the SCRIPT_DIR-relative paths to point at our temp env
  sed -i "s|SCRIPT_DIR=\"\$(cd \"\$(dirname \"\$0\")\" && pwd)\"|SCRIPT_DIR=\"$dir/scripts\"|g" \
    "$dir/scripts/promote-to-regression.sh"
}

echo ""
echo "=== req-014: regression-pack infrastructure ==="

# ── Section 1: promote-to-regression.sh happy path ───────────────────────────
echo ""
echo "--- promote-to-regression.sh: happy path ---"

ENV1="$TMPDIR_BASE/env1"
make_env "$ENV1"

# Create a source test file
TEST_SRC="$TMPDIR_BASE/my-test.sh"
printf '#!/usr/bin/env bash\necho "test"\n' > "$TEST_SRC"

output=$(bash "$ENV1/scripts/promote-to-regression.sh" "$TEST_SRC" "0000004-test" "human" 2>&1)
code=$?
assert_equals "0" "$code" "promote exits 0 on happy path"
assert_contains "Promotion complete" "$output" "promote reports completion"

# File should be copied
if [ -f "$ENV1/tests/regression/my-test.sh" ]; then
  echo "  PASS: test file copied to regression dir"
  ((PASS++)) || true
else
  echo "  FAIL: test file not copied to regression dir"
  ((FAIL++)) || true
fi

# Manifest should have one entry
manifest_count=$(node -e "
const m = JSON.parse(require('fs').readFileSync('$ENV1/tests/regression/regression-manifest.json','utf8'));
console.log(m.tests.length);
" 2>/dev/null)
assert_equals "1" "$manifest_count" "manifest has 1 entry after promotion"

# Check fields
manifest_name=$(node -e "
const m = JSON.parse(require('fs').readFileSync('$ENV1/tests/regression/regression-manifest.json','utf8'));
console.log(m.tests[0].name);
" 2>/dev/null)
assert_equals "my-test.sh" "$manifest_name" "manifest entry has correct name"

manifest_promoted_by=$(node -e "
const m = JSON.parse(require('fs').readFileSync('$ENV1/tests/regression/regression-manifest.json','utf8'));
console.log(m.tests[0].promotedBy);
" 2>/dev/null)
assert_equals "human" "$manifest_promoted_by" "manifest entry has promotedBy=human"

# ── Section 2: idempotency ────────────────────────────────────────────────────
echo ""
echo "--- promote-to-regression.sh: idempotency ---"

output2=$(bash "$ENV1/scripts/promote-to-regression.sh" "$TEST_SRC" "0000004-test" "human" 2>&1)
code2=$?
assert_equals "0" "$code2" "second promotion run exits 0 (idempotent)"
assert_contains "already in the regression pack" "$output2" "second run reports already promoted"

manifest_count2=$(node -e "
const m = JSON.parse(require('fs').readFileSync('$ENV1/tests/regression/regression-manifest.json','utf8'));
console.log(m.tests.length);
" 2>/dev/null)
assert_equals "1" "$manifest_count2" "manifest still has 1 entry (no duplicate) after second run"

# ── Section 3: missing source file ───────────────────────────────────────────
echo ""
echo "--- promote-to-regression.sh: missing source file ---"

ENV3="$TMPDIR_BASE/env3"
make_env "$ENV3"

output3=$(bash "$ENV3/scripts/promote-to-regression.sh" "/nonexistent/file.sh" "0000004-test" "human" 2>&1)
code3=$?
assert_equals "1" "$code3" "promote exits 1 when source file missing"
assert_contains "not found" "$output3" "promote reports file not found"

# ── Section 4: manifest is valid JSON after promotion ────────────────────────
echo ""
echo "--- regression-manifest.json: valid JSON ---"

node -e "JSON.parse(require('fs').readFileSync('$ENV1/tests/regression/regression-manifest.json','utf8'));" 2>/dev/null
json_valid=$?
assert_equals "0" "$json_valid" "manifest is valid JSON after promotion"

# ── Section 5: run-tests.sh regression block — empty dir ─────────────────────
echo ""
echo "--- run-tests.sh regression block: empty regression dir ---"

# The real regression dir should either be empty (gitkeep only) or have tests
# We test the empty-pack case using a subshell override
RUN_TESTS="$SCRIPT_DIR/run-tests.sh"

# If real regression dir has no test-*.sh files, run-tests.sh should exit 0
real_regression_tests=("$REAL_REGRESSION_DIR"/test-*.sh)
if [ ! -e "${real_regression_tests[0]}" ]; then
  output5=$(bash "$RUN_TESTS" 2>&1)
  code5=$?
  assert_equals "0" "$code5" "run-tests.sh exits 0 with empty regression dir"
  assert_contains "No regression tests yet" "$output5" "run-tests.sh reports no regression tests"
else
  echo "  SKIP: regression dir has tests — empty-dir case not testable without modification"
  ((PASS++)) || true
fi

# ── Section 6: run-tests.sh — regression block present in output ─────────────
echo ""
echo "--- run-tests.sh regression block: block header present ---"

output6=$(bash "$RUN_TESTS" 2>&1)
if printf '%s' "$output6" | grep -qF "=== Regression Suite ==="; then
  echo "  PASS: run-tests.sh output contains regression suite header"
  ((PASS++)) || true
else
  echo "  FAIL: run-tests.sh output missing regression suite header"
  ((FAIL++)) || true
fi

if printf '%s' "$output6" | grep -qF "Regression suite:"; then
  echo "  PASS: run-tests.sh summary contains regression suite counts"
  ((PASS++)) || true
else
  echo "  FAIL: run-tests.sh summary missing regression suite counts"
  ((FAIL++)) || true
fi

print_summary
