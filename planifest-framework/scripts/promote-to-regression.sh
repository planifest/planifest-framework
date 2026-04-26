#!/usr/bin/env bash
# promote-to-regression.sh — promote a test file into the long-term regression pack.
#
# Usage:
#   promote-to-regression.sh <test-file-path> <source-feature-id> <promoted-by>
#
# Arguments:
#   test-file-path    — path to the test file to promote (must exist)
#   source-feature-id — feature ID the test originated from (e.g. 0000004-tdd-regression-test-quality)
#   promoted-by       — "agent" or "human"
#
# Idempotent: running twice with the same test file produces no duplicate manifest entries.
#
# Exit codes:
#   0 — success (or already promoted, idempotent)
#   1 — usage error or precondition failure

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGRESSION_DIR="$SCRIPT_DIR/../tests/regression"
MANIFEST="$REGRESSION_DIR/regression-manifest.json"

die() { echo "ERROR: $*" >&2; exit 1; }

# ── Argument validation ───────────────────────────────────────────────────────

[ $# -eq 3 ] || die "Usage: promote-to-regression.sh <test-file-path> <source-feature-id> <promoted-by>"

TEST_FILE="$1"
SOURCE_FEATURE="$2"
PROMOTED_BY="$3"

[ -f "$TEST_FILE" ] || die "Test file not found: $TEST_FILE"

case "$PROMOTED_BY" in
  agent|human) ;;
  *) die "promoted-by must be 'agent' or 'human', got: $PROMOTED_BY" ;;
esac

[ -f "$MANIFEST" ] || die "Manifest not found: $MANIFEST"

# ── Idempotency check ─────────────────────────────────────────────────────────

BASENAME="$(basename "$TEST_FILE")"
DEST="$REGRESSION_DIR/$BASENAME"

# Check if this test name is already in the manifest
ALREADY_PROMOTED=false
if node -e "
const fs = require('fs');
const m = JSON.parse(fs.readFileSync('$MANIFEST', 'utf8'));
const found = (m.tests || []).some(t => t.name === '$BASENAME');
process.exit(found ? 0 : 1);
" 2>/dev/null; then
  ALREADY_PROMOTED=true
fi

if [ "$ALREADY_PROMOTED" = "true" ]; then
  echo "INFO: $BASENAME is already in the regression pack — skipping (idempotent)."
  exit 0
fi

# ── Copy test file ────────────────────────────────────────────────────────────

cp "$TEST_FILE" "$DEST" || die "Failed to copy $TEST_FILE to $DEST"
echo "  copied: $BASENAME → tests/regression/"

# ── Update manifest ───────────────────────────────────────────────────────────

PROMOTION_DATE="$(date +%Y-%m-%d)"
RELATIVE_PATH="tests/regression/$BASENAME"

node -e "
const fs = require('fs');
const manifestPath = '$MANIFEST';
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
if (!Array.isArray(manifest.tests)) { manifest.tests = []; }
manifest.tests.push({
  name: '$BASENAME',
  sourceFeature: '$SOURCE_FEATURE',
  promotionDate: '$PROMOTION_DATE',
  promotedBy: '$PROMOTED_BY',
  filePath: '$RELATIVE_PATH'
});
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
" || die "Failed to update regression manifest"

echo "  manifest updated: $BASENAME promoted by $PROMOTED_BY from $SOURCE_FEATURE on $PROMOTION_DATE"
echo "Promotion complete: $BASENAME"
