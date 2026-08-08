---
title: "Backlog Entry: 0000063 - Telemetry hooks record a routine daemon restart as a durable emission failure"
summary: "All three telemetry hooks POST to the backend with no retry, so the ~1-2s window where a consuming product restarts its own telemetry daemon produces a durable failure marker and an orchestrator block-or-proceed interrupt for something that self-corrects. A verified fix exists downstream for one of the three hooks; the diff is embedded below."
status: "open"
---
# Backlog Entry: 0000063 - Telemetry hooks record a routine daemon restart as a durable emission failure

**Source feature:** filed from downstream repo `structured-telemetry-mcp`, feature `0000018-telemetry-data-integrity`
**Source phase:** P3 (codegen) — surfaced live, mid-run
**Deferral source:** discovered mid-flight
**Date filed:** 2026-08-08

---

## Problem

All three telemetry hooks emit with a single, unretried `fetch`:

| Hook | `await fetch(...)` | Writes failure marker |
|------|--------------------|-----------------------|
| `hooks/telemetry/context-pressure.mjs` | line 212 | yes (3 call sites) |
| `hooks/telemetry/emit-phase-start.mjs` | line 217 | yes (3 call sites) |
| `hooks/telemetry/emit-phase-end.mjs` | line 206 | yes (3 call sites) |

A network-level connection failure is therefore treated identically to a real, persistent emission failure: the hook writes a durable marker to `plan/.telemetry-failures/`, which the orchestrator (and now `check-telemetry-failures.mjs`, added in 0000026) surfaces as a block-or-proceed question to the human on the loop.

That is correct behaviour for a backend that is genuinely down. It is wrong for the specific, routine, self-correcting case of **the telemetry backend restarting itself** — which is exactly what happens when the consuming product *is* `structured-telemetry-mcp` and someone runs `npm run deploy`. Between the old daemon exiting and the new one binding the port, there is a ~1–2 second window with no listener. Any hook firing in that window sees `fetch` reject with a `TypeError`, and the framework records a failure that was never real.

**This was observed, not theorised.** During `0000018`'s P3, a subagent verifying that feature's own deploy tooling ran several real `npm run deploy` restarts. That produced **10 occurrences** of `context-pressure::TypeError::fetch-failed` in `plan/.telemetry-failures/` between 09:10:25Z and 09:15:53Z, which halted the pipeline at the next phase boundary for a block-or-proceed decision. The daemon was healthy throughout; nothing had actually failed.

The asymmetry worth noting: a *network-level* failure (`fetch` rejecting) is the signature of a listener gap and is frequently transient. An *HTTP error status* (4xx/5xx) means a listener answered and rejected the event — that is a real failure and should never be retried. The current code cannot distinguish them because it does not try.

## Suggested Action

Apply a bounded retry to the network-level failure path only, in **all three hooks** — the downstream fix covered only `context-pressure.mjs`, because that was the only one that had actually fired during the incident. The other two carry the identical defect.

Constraints that should survive the change:

- **NFR-001 (never block the session) is unchanged** — the hook still exits 0 on exhaustion.
- **NFR-002 (no local fallback) is unchanged** — this is not a queue. A failure is still dropped, and still recorded via the durable marker. Only the *definition of failure* narrows.
- Worst-case added latency must stay inside a hook's budget. The downstream fix uses 2 retries at fixed 300ms gaps → ~600ms worst case, on top of the existing per-attempt 3s abort.
- Retry **must not** fire on an HTTP error status. The downstream fix keys off the synthetic `err.name` (`http_<status>`) the hooks already set, so `!err.name.startsWith("http_")` identifies a network-level failure.

Worth deciding upstream rather than inheriting from the downstream patch: whether 2×300ms is the right budget, whether the delays should be shared as a single constant across the three hooks (they currently duplicate the whole emit block), and whether this is the moment to extract the triplicated emit-and-record logic into one shared module — the three hooks are near-identical in this region, and this fix has to be applied three times precisely because they are.

### Verified diff (from the downstream repo)

Baseline is release `0.26.1`'s `context-pressure.mjs`; the patched version is what `structured-telemetry-mcp` now carries on `main`. This is a straight port candidate for the other two hooks.

```diff
--- a/hooks/telemetry/context-pressure.mjs	(release 0.26.1)
+++ b/hooks/telemetry/context-pressure.mjs	(patched)
@@ -12,8 +12,26 @@
  * it grows proportionally with context use within a session and resets at
  * session start. It does not account for compaction events.
  *
- * Silent on all errors (NFR-001). No retries. No local fallback (NFR-002).
+ * Silent on all errors (NFR-001). No local fallback (NFR-002) — a failure
+ * is never queued or persisted for later delivery, it is dropped (with a
+ * durable marker recording *that* it was dropped, per req-002/ADR-002).
  *
+ * Bounded retry for connection-refused only (0000018, filed against this
+ * repo directly): a `structured-telemetry-mcp` deploy briefly leaves no
+ * listener on BACKEND_URL between the old daemon exiting and the new one
+ * binding the port (req-001/002 checkpoint on exit; launchd/systemd then
+ * relaunches). A hook firing in that ~1-2s window saw a network-level
+ * connection failure (fetch's TypeError, not an HTTP error status) and
+ * treated a routine, self-correcting restart as a hard failure, tripping
+ * the durable-marker/human-interrupt path for something that was never
+ * actually wrong. Retries up to 2 times (3 attempts total), fixed 300ms
+ * gaps, only on a network-level fetch failure — never on an HTTP error
+ * response (4xx/5xx are real failures, not a listener gap, and are not
+ * retried). Total added worst-case latency ~600ms, still well inside a
+ * hook's "must be fast" budget. This is not a general retry/queue
+ * mechanism — a backend that is still unreachable after 3 attempts is
+ * still recorded via the durable marker exactly as before.
+ *
  * Durable failure marker (req-002, ADR-002): on emission failure this hook
  * still exits 0 and never blocks (NFR-001 unchanged) — but it now also
  * writes a best-effort marker file recording the root cause, instead of
@@ -205,24 +223,39 @@
     },
   };
 
-  // Fire-and-forget: abort after 3 s to keep the hook fast.
-  const ac = new AbortController();
-  const timer = setTimeout(() => ac.abort(), 3_000);
-  try {
-    const res = await fetch(`${BACKEND_URL}/emit`, {
-      method: "POST",
-      headers: { "Content-Type": "application/json" },
-      body: JSON.stringify(event),
-      signal: ac.signal,
-    });
-    if (!res.ok) {
-      const httpErr = new Error(`emission POST failed: HTTP ${res.status}`);
-      httpErr.name = `http_${res.status}`;
-      throw httpErr;
+  // Fire-and-forget: abort each attempt after 3 s to keep the hook fast.
+  const RETRY_DELAYS_MS = [300, 300]; // up to 2 retries (3 attempts total)
+  let lastErr;
+  for (let attempt = 0; ; attempt++) {
+    const ac = new AbortController();
+    const timer = setTimeout(() => ac.abort(), 3_000);
+    try {
+      const res = await fetch(`${BACKEND_URL}/emit`, {
+        method: "POST",
+        headers: { "Content-Type": "application/json" },
+        body: JSON.stringify(event),
+        signal: ac.signal,
+      });
+      if (!res.ok) {
+        const httpErr = new Error(`emission POST failed: HTTP ${res.status}`);
+        httpErr.name = `http_${res.status}`;
+        throw httpErr;
+      }
+      lastErr = null;
+      break;
+    } catch (err) {
+      lastErr = err;
+      // Only retry a network-level failure (e.g. ECONNREFUSED surfaced by
+      // fetch as a TypeError) — a real HTTP error status is never a
+      // listener-gap symptom and is not worth retrying.
+      const isNetworkFailure = !(err?.name ?? "").startsWith("http_");
+      if (!isNetworkFailure || attempt >= RETRY_DELAYS_MS.length) break;
+    } finally {
+      clearTimeout(timer);
     }
-  } finally {
-    clearTimeout(timer);
+    await new Promise((r) => setTimeout(r, RETRY_DELAYS_MS[attempt]));
   }
+  if (lastErr) throw lastErr;
 } catch (err) {
   // PostToolUse must never block the session — silent fallback (NFR-001).
   recordTelemetryFailure("context-pressure", err, { cwd, phase: "monitoring", sessionId });
```

### How the downstream fix was verified

Two cases, run against the real hook as a spawned child process with a controllable backend, not by inspection:

1. **Nothing ever listening** — hook exits 0 after ~684ms (the two 300ms gaps plus overhead), and the durable marker is still written. Pre-existing behaviour preserved exactly; a genuinely-down backend is still reported.
2. **Listener appears 350ms in** (simulating the daemon mid-restart) — hook exits 0 at ~416ms, the event is received by the backend, and **no marker is written**. This is the case that previously produced a spurious failure.

It has since run live through several pipeline phases in the downstream repo with no further spurious markers.

## Why Deferred

Filed from a downstream repo that vendors this framework but does not maintain it. The fix belongs to `hooks/telemetry/*.mjs` here.

The downstream project is not blocked — it carries the patch locally on its vendored copy, recorded under a `LOCAL PATCH` note in its `planifest-framework/component.yml`. That patch is fragile by construction: `update-planifest-framework.local-only.sh` does `rm -rf planifest-framework && cp -R <release>`, so the next framework update silently drops it. It was in fact already dropped once during the `0000018` run and had to be restored from git. Upstreaming it here is what makes it durable; until then, every downstream framework update re-introduces the bug.

Related: `0000026` added `check-telemetry-failures.mjs`, which makes these markers *more* visible by injecting a reminder on every `UserPromptSubmit`. That is the correct behaviour for real failures, and it raises the cost of the false positives this entry describes — a spurious marker is now surfaced persistently until acknowledged, rather than only at a phase boundary.
