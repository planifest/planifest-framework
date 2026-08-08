#!/usr/bin/env bash
# test-0000028-req-004-install-refresh-registration.sh
#
# REQ-004 asserts an operational outcome: after a refresh, the phase telemetry
# hooks are registered and telemetry receipts stay out of version control.
#
# The live-firing half of that outcome belongs to REQ-005 and cannot be
# asserted here. A hook firing requires a real host tool session, which is
# exactly why backlog 0000058 existed and why its evidence lives in
# plan/current/verification-report.md rather than in this file. What IS
# assertable without a live session is covered below: that setup.sh contains
# the wiring, that the shared modules reach every install tier, and that the
# receipts path is ignored by git.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$REPO_ROOT/planifest-framework"

source "$SCRIPT_DIR/helpers/assert.sh"

SETUP_SH="$FRAMEWORK_DIR/setup.sh"
setup_content=$(cat "$SETUP_SH")

echo "=== req-004: setup.sh wires every phase telemetry hook ==="

assert_contains "merge_telemetry_hook_settings" "$setup_content" \
  "req-004: setup.sh defines merge_telemetry_hook_settings"

for wiring in "resolve-phase.mjs start" "resolve-phase.mjs end" "emit-event-receipt.mjs"; do
  assert_contains "$wiring" "$setup_content" \
    "req-004: setup.sh wires $wiring"
done

assert_contains "mcp__structured-telemetry-mcp__emit_event" "$setup_content" \
  "req-004: receipt hook is matched on the emit_event MCP tool call"

echo ""
echo "=== req-004: shared modules reach tier 1 installs ==="

# The tier 1 telemetry copy globbed emit-phase-*.mjs, which would silently drop
# any shared module and break the req-002 extraction for Cursor, Windsurf and
# Cline. Assert the narrow glob is gone rather than merely that a wide one
# exists somewhere in the file.
tier1_narrow=$(printf '%s' "$setup_content" | grep -c 'telem_src"/emit-phase-\*\.mjs' || true)
assert_equals "0" "$tier1_narrow" \
  "req-004: tier 1 telemetry install no longer globs only emit-phase-*.mjs"

echo ""
echo "=== req-004: telemetry receipts stay out of version control ==="

# Receipts are written per successful emit_event and, like failure markers, can
# echo user-configured URL and error strings. Both must be ignored.
cd "$REPO_ROOT"
receipts_ignored=$(git check-ignore -q plan/.telemetry-receipts/probe.json && echo yes || echo no)
assert_equals "yes" "$receipts_ignored" \
  "req-004: plan/.telemetry-receipts/ is gitignored"

markers_ignored=$(git check-ignore -q plan/.telemetry-failures/probe.json && echo yes || echo no)
assert_equals "yes" "$markers_ignored" \
  "req-004: plan/.telemetry-failures/ is still gitignored"

print_summary
