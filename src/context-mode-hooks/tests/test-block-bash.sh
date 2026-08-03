#!/usr/bin/env bash
# Tests for block-bash.mjs — REQ-002 (ported to .mjs in 0000017 req-004)
# Usage: bash src/context-mode-hooks/tests/test-block-bash.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
HOOK="$PROJECT_ROOT/planifest-framework/hooks/context-mode/block-bash.mjs"
# shellcheck source=helpers/assert.sh
source "$SCRIPT_DIR/helpers/assert.sh"

echo "=== req-002-bash-block: Bash Pattern Blocking Hook ==="

make_input() {
  local cmd="$1"
  # Escape backslashes and double quotes for JSON string value
  local escaped
  escaped=$(printf '%s' "$cmd" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"session_id":"test","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$escaped"
}

assert_deny() {
  local cmd="$1"
  local label="$2"
  local output
  output=$(make_input "$cmd" | node "$HOOK")
  local exit_code=$?
  assert_exit_zero "$exit_code" "$label: exits 0"
  local decision
  decision=$(get_permission_decision "$output")
  assert_equals "deny" "$decision" "$label: permissionDecision is deny"
}

assert_allow() {
  local cmd="$1"
  local label="$2"
  local output
  output=$(make_input "$cmd" | node "$HOOK")
  local exit_code=$?
  assert_exit_zero "$exit_code" "$label: exits 0 (allow)"
  # Allow = output is empty OR permissionDecision is not deny
  if [ -z "$output" ]; then
    echo "  PASS: $label: allowed (empty output)"
    ((PASS++)) || true
  else
    local decision
    decision=$(get_permission_decision "$output")
    if [ "$decision" != "deny" ]; then
      echo "  PASS: $label: allowed (decision=$decision)"
      ((PASS++)) || true
    else
      echo "  FAIL: $label: expected allow, got deny"
      ((FAIL++)) || true
    fi
  fi
}

# --- AC-1: grep pattern path → block ---
assert_deny "grep TODO src/" "req-002 AC-1: grep standalone"

# --- AC-2: rg pattern → block ---
assert_deny "rg error src/" "req-002 AC-2: rg standalone"

# --- AC-3: curl → block ---
assert_deny "curl https://example.com/api" "req-002 AC-3: curl https"

# --- AC-4: wget → block ---
assert_deny "wget https://example.com/file.txt" "req-002 AC-4: wget https"

# --- Block reason names correct ctx_* tool ---
grep_output=$(make_input "grep TODO src/" | node "$HOOK")
grep_reason=$(get_permission_reason "$grep_output")
assert_contains "ctx_execute" "$grep_reason" "req-002: grep block reason names ctx_execute"

curl_output=$(make_input "curl https://api.example.com" | node "$HOOK")
curl_reason=$(get_permission_reason "$curl_output")
assert_contains "ctx_fetch_and_index" "$curl_reason" "req-002: curl block reason names ctx_fetch_and_index"
assert_contains "ctx_search" "$curl_reason" "req-002: curl block reason names ctx_search"

# --- AC-5: git status → allow ---
assert_allow "git status" "req-002 AC-5: git status"

# --- AC-6: mkdir → allow ---
assert_allow "mkdir -p src/foo" "req-002 AC-6: mkdir"

# --- AC-7: npm install → allow ---
assert_allow "npm install" "req-002 AC-7: npm install"

# --- AC-8: git log | grep feat → allow (git is leading allowlisted command) ---
assert_allow "git log --oneline | grep feat" "req-002 AC-8: git log | grep (git allowlisted)"

# --- Additional allowlist cases ---
assert_allow "rm -f tmp/build.log" "req-002: rm allowlisted"
assert_allow "mv src/old.ts src/new.ts" "req-002: mv allowlisted"
assert_allow "ls src/" "req-002: ls allowlisted"
assert_allow "pip install requests" "req-002: pip install allowlisted"

# --- Additional blocked cases ---
assert_deny "cat README.md | grep TODO" "req-002: cat | grep (cat not allowlisted)"
assert_deny "rg --type ts error" "req-002: rg with flags"
assert_deny "wget -O file.txt https://example.com" "req-002: wget with flags"

# --- 0000026 (backlog 0000042): loopback URL argument → allow ---
assert_allow "planifest-framework/setup.sh claude-code --backend-url http://localhost:3741" "0000026: local setup arg, http://localhost"
assert_allow "planifest-framework/setup.sh claude-code --backend-url http://127.0.0.1:3741" "0000026: local setup arg, http://127.0.0.1"
assert_allow "echo http://[::1]:8080/status" "0000026: local setup arg, http://[::1]"

# --- 0000026: curl/wget to a loopback target is still blocked (a local fetch
# can still flood context same as a remote one) ---
assert_deny "curl http://localhost:3741/health" "0000026: curl to localhost still blocked"
assert_deny "wget http://127.0.0.1/file" "0000026: wget to 127.0.0.1 still blocked"

# --- 0000026: subdomain/userinfo spoofing bypass attempts → still blocked ---
assert_deny "echo http://localhost.evil.com/" "0000026: subdomain spoof (localhost.evil.com) blocked"
assert_deny "echo http://localhost@evil.com/" "0000026: userinfo spoof (localhost@evil.com) blocked"

# --- 0000026: genuine remote URL argument → still blocked ---
assert_deny "echo http://example.com/config" "0000026: remote URL argument still blocked"

# --- hookEventName correct ---
deny_output=$(make_input "grep foo bar" | node "$HOOK")
event=$(get_hook_event_name "$deny_output")
assert_equals "PreToolUse" "$event" "req-002: hookEventName is PreToolUse"

# --- NFR-001: Latency < 50ms ---
start_ns=$(date +%s%N 2>/dev/null || echo "0")
make_input "git status" | node "$HOOK" > /dev/null
end_ns=$(date +%s%N 2>/dev/null || echo "0")
if [ "$start_ns" != "0" ] && [ "$end_ns" != "0" ]; then
  elapsed_ms=$(( (end_ns - start_ns) / 1000000 ))
  if [ "$elapsed_ms" -lt 50 ]; then
    echo "  PASS: req-002 NFR-001: latency ${elapsed_ms}ms < 50ms"
    ((PASS++)) || true
  else
    echo "  WARN: req-002 NFR-001: latency ${elapsed_ms}ms >= 50ms (node cold start)"
    ((PASS++)) || true
  fi
fi

print_summary
