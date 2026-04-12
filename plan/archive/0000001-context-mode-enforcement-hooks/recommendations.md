# Recommendations — 0000001-context-mode-enforcement-hooks

**Date:** 2026-04-12
**Produced by:** planifest-docs-agent (Phase 6)

---

## Before Merging

### 1. Run REQ-004 manual smoke test
**Priority: High**

The setup integration (REQ-004) has no automated test. Before merging, run:
```bash
./planifest-framework/setup.sh claude-code --context-mode-mcp
```
in a test repository and verify the checklist in `plan/current/pipeline-run.md`. This is the only gap between 55/55 automated assertions and full requirements coverage.

### 2. Fix component.yml contract description (TD-002)
**Priority: Low**

`src/context-mode-hooks/component.yml` line 49 describes the output schema using the deprecated `{decision: block|allow}` format. Update to reflect the actual `hookSpecificOutput` envelope. This is documentation drift — no functional impact, but will mislead anyone reading the manifest.

---

## Before Upstream Contribution (ADR-004)

### 3. Add input size guard to `block-bash.sh`
**Priority: Low**

Per security-report.md finding 1 and tech-debt TD-001: add `head -c 65536` (or `ulimit -v`) before `command=$(cat)` to prevent memory exhaustion from oversized stdin. Not required for local dev use, but good hygiene before publishing to `mksglu/context-mode`.

### 4. Add smoke test to REQ-004 checklist: verify deny reason is surfaced
**Priority: Low**

Per security-report.md finding 2: add an explicit check that Claude Code actually surfaces the `permissionDecisionReason` text to the agent in the UI — not just that the hook writes valid JSON. A silent schema change to `hookSpecificOutput` would cause hooks to exit 0 with unrecognised JSON, allowing tool calls through.

---

## Future Iterations

### 5. Configurable allowlist (deferred in ADR-002)
**Priority: Medium (next iteration)**

The hardcoded allowlist in `block-bash.sh` will need expansion as agent workflows grow. Implement a `.planifest/context-mode.json` config file with per-project allowlist overrides. Design must solve for:
- Latency budget (disk I/O adds ~1-2ms — acceptable)
- Config schema validation
- Merge with default allowlist vs. replace

### 6. jq install guidance in getting-started.md
**Priority: Low**

Per security-report.md finding 3 and quirks Q-002: add a `jq` installation note to `getting-started.md` under the context-mode setup section. Without `jq`, hooks fall back to Node.js cold start (~250ms), missing the < 50ms NFR on Windows.

### 7. Add `FORCE_NODE_FALLBACK=1` test coverage (TD-003)
**Priority: Info**

Add an env var to force the `node` fallback path in hook scripts, and corresponding test assertions. This ensures both paths are tested regardless of which JSON tool is available in the test environment.

### 8. Upstream contribution to mksglu/context-mode
**Priority: Post-pipeline**

After REQ-004 smoke test passes and TD-001 is resolved, open a PR to `https://github.com/mksglu/context-mode` with the three hook scripts. Until the PR is merged, `planifest-framework/hooks/context-mode/` is the source of truth. See ADR-004.
