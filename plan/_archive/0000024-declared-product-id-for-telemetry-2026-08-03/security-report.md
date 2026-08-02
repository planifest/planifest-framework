# Security Report - 0000024-declared-product-id-for-telemetry

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| A malicious/compromised `product.yml` `id` value inflates the telemetry POST body size (very long string committed to the file) | DoS | Low | `readProductId()` has no length cap. Not mitigated in code, but `product.yml` is committed source requiring repo write access — same trust boundary as any other source file an insider could edit; not an externally-reachable input. Accepted risk, not a code fix required. |
| `id` value containing YAML-breaking characters (unescaped `"`, `'`) causes `readProductId()` to throw "malformed (unbalanced quoting)" | Tampering / availability of telemetry | Low | Mitigated by design — treated as an emission failure, routed to `recordTelemetryFailure()`, hook still exits 0 (ADR-005). Fails safe, not silently. |
| `id` value containing control characters or JSON-breaking characters reaches the telemetry backend | Info disclosure / injection | Low | Not exploitable — `JSON.stringify(event)` (emit-phase-start.mjs:220, identical pattern in the other 2 hooks) serialises the full envelope including `product_id`, which auto-escapes quotes/control characters per the JSON spec. No string concatenation into the request body anywhere in the 3 hooks. |
| Regex-based YAML parsing in `readProductId()` is exploited via a crafted `product.yml` to cause catastrophic backtracking (ReDoS) | DoS | Low | Not present — all 4 regexes (`/^id:\s*(.*)$/`, `/^"[^"]*"$/`, `/^'[^']*'$/`, `/["']/`) are linear-time; none contain nested quantifiers or ambiguous alternation. Confirmed by direct inspection, no catastrophic-backtracking pattern exists. |
| A component-list item's `id` field (e.g. `components: [{id: "x"}]`, valid per multi-component `product.yml` per 0000016 ADR-002) is mistakenly matched instead of the top-level `id` | Tampering (wrong product_id) | Low | Not exploitable — the regex `^id:\s*(.*)$` anchors to line start with no leading whitespace tolerance; nested/indented component-list entries (e.g. `  - id: x`) never match. Confirmed correct by design: the top-level `id` is always the first (and only) match in file order. |
| Human's answer to the orchestrator's P0 hard-stop prompt (`planifest-orchestrator/SKILL.md` step 3b) contains a `"` character, breaking the `id: "{declared-id}"` YAML written to `product.yml` | Tampering (malformed config) | Low | The SKILL.md instruction as written does not explicitly tell the implementing agent to escape/quote-guard the human's answer before interpolating it into `product.yml`. This is a prose-instruction gap, not a code defect (no code path implements this write mechanically — it's agent-driven each time). Recommend a doc clarification (non-blocking, filed as a recommendation below) rather than a blocking finding, since the trust boundary is the human on the loop typing into their own project's config, not an external attacker. |
| `PLANIFEST_TELEMETRY_URL` misconfigured to an untrusted endpoint receives the declared `product_id` | Info disclosure | Low | Pre-existing, unchanged risk (already in `planifest-framework/component.yml`'s risk register: "Telemetry backend URL is env-var controlled — misconfiguration sends events to wrong endpoint"). `product_id` is a low-sensitivity, human-chosen name — no new exposure surface versus the previous git-path value (which was arguably more revealing, exposing local filesystem structure). |

## Dependency Audit

No new dependencies introduced. `readProductId()` uses only `node:fs` (`readFileSync`, already imported in all 3 files pre-existing). No package manifest exists for this component (bash/Node hook scripts, no `package.json`).

## Secrets Management

No secrets involved. `product.yml`'s `id` field is a human-chosen, non-sensitive product name, committed as plain-text source — same classification as `component.yml`'s existing `id` field.

## Authentication & Authorisation Review

Not applicable — no API surface, no auth changes. `product.yml` read access is filesystem-local, gated by the same repo access any hook subprocess already has.

## Input Validation Review

Not applicable in the OpenAPI sense (no API), but `readProductId()` is the closest analogue — see Threat Model above. Findings: no length cap on `id` (accepted, low severity, non-externally-reachable), no ReDoS risk (confirmed), no injection risk into the POST body (confirmed, `JSON.stringify` handles escaping), no false-positive match against component-list `id` entries (confirmed).

## Network Policy

Unchanged — the 3 hooks POST to the same `PLANIFEST_TELEMETRY_URL`/`emit` endpoint as before this feature; `product_id`'s source changed, the network surface did not.

## Infrastructure as Code Review

Not applicable — no IaC in this feature's stack.

## Summary

Overall risk rating: **Low**

Top actions before production:
1. None blocking — all findings are Low severity, several already mitigated by design (fail-safe via `recordTelemetryFailure()`, JSON escaping, anchored regex).
2. Recommended (non-blocking, for `recommendations.md`): clarify in `planifest-orchestrator/SKILL.md` step 3b that the human's declared-id answer should be quote-escaped before being written into `product.yml`'s YAML, to avoid a malformed file if the answer happens to contain a `"` character.
3. Recommended (non-blocking, for `recommendations.md`): consider a soft length cap or sanity check on `readProductId()`'s returned value in a future iteration, purely as defence-in-depth — not required now given the trust boundary (committed source, not external input).
