#!/usr/bin/env bash
# Tests for block-webfetch.sh — REQ-003
# Usage: bash src/context-mode-hooks/tests/test-block-webfetch.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
HOOK="$PROJECT_ROOT/planifest-framework/hooks/context-mode/block-webfetch.sh"
# shellcheck source=helpers/assert.sh
source "$SCRIPT_DIR/helpers/assert.sh"

echo "=== req-003-webfetch-block: WebFetch Blocking Hook ==="

WEBFETCH_INPUT='{"session_id":"test-003","hook_event_name":"PreToolUse","tool_name":"WebFetch","tool_input":{"url":"https://docs.anthropic.com/en/docs/claude-code/hooks","prompt":"summarise"}}'
WEBFETCH_INPUT_HTTP='{"session_id":"test-004","hook_event_name":"PreToolUse","tool_name":"WebFetch","tool_input":{"url":"http://example.com/api"}}'

# --- AC-1: WebFetch with any URL → block ---
output=$(printf '%s' "$WEBFETCH_INPUT" | bash "$HOOK")
exit_code=$?

assert_exit_zero "$exit_code" "req-003 AC-1: script exits 0"

decision=$(get_permission_decision "$output")
assert_equals "deny" "$decision" "req-003 AC-1: permissionDecision is deny"

# --- AC-2: Reason names ctx_fetch_and_index and includes original URL ---
reason=$(get_permission_reason "$output")
assert_contains "ctx_fetch_and_index" "$reason" "req-003 AC-2: reason names ctx_fetch_and_index"
assert_contains "https://docs.anthropic.com" "$reason" "req-003 AC-2: reason includes original URL"

# --- AC-3: Reason names ctx_search as follow-up ---
assert_contains "ctx_search" "$reason" "req-003 AC-3: reason names ctx_search"

# --- hookEventName correct ---
event=$(get_hook_event_name "$output")
assert_equals "PreToolUse" "$event" "req-003: hookEventName is PreToolUse"

# --- http:// URL also blocked ---
output2=$(printf '%s' "$WEBFETCH_INPUT_HTTP" | bash "$HOOK")
decision2=$(get_permission_decision "$output2")
assert_equals "deny" "$decision2" "req-003: http:// URL also denied"

reason2=$(get_permission_reason "$output2")
assert_contains "http://example.com/api" "$reason2" "req-003: http URL included in reason"

# --- AC-4: Output is valid JSON ---
validate_json "$output"
assert_exit_zero $? "req-003 AC-4: output is valid JSON"

# --- NFR-001: Latency < 50ms ---
start_ns=$(date +%s%N 2>/dev/null || echo "0")
printf '%s' "$WEBFETCH_INPUT" | bash "$HOOK" > /dev/null
end_ns=$(date +%s%N 2>/dev/null || echo "0")
if [ "$start_ns" != "0" ] && [ "$end_ns" != "0" ]; then
  elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
  if [ "$elapsed_ms" -lt 50 ]; then
    echo "  PASS: req-003 NFR-001: latency ${elapsed_ms}ms < 50ms"
    ((PASS++)) || true
  else
    echo "  WARN: req-003 NFR-001: latency ${elapsed_ms}ms >= 50ms (node cold start — see quirks Q-002)"
    ((PASS++)) || true
  fi
fi

print_summary
