/**
 * Shared hook helper: POST a telemetry envelope to the backend.
 *
 * Extracted per req-002 / 0000028-ADR-002 from the 3 copies of the
 * fetch/AbortController block in context-pressure.mjs, emit-phase-start.mjs
 * and emit-phase-end.mjs. Behaviour is unchanged from those copies:
 * fire-and-forget POST to `${backendUrl}/emit`, aborted after 3 seconds, with
 * a non-ok response converted into a synthetic `http_<status>` error thrown to
 * the caller's own top-level try/catch (which routes it to
 * recordTelemetryFailure()).
 *
 * Only the post-event mechanics are shared. Each hook still builds its own
 * event object locally, because the `context_pressure`, `phase_start` and
 * `phase_end` payloads genuinely differ.
 *
 * req-001 dependency (0000028-ADR-001): the bounded network-level retry loop
 * belongs inside this function when req-001 lands, so it is added once here
 * rather than re-duplicated across the three callers a third time. As of
 * req-002 this module carries the pre-retry semantics verbatim.
 *
 * PLACEMENT: hooks/telemetry/. All 3 callers are telemetry hooks, and
 * setup.sh's Tier 1 telemetry glob was widened to *.mjs (req-002) so Tier 1
 * installs receive this file alongside them.
 */

const ABORT_MS = 3_000;

/**
 * Throws on transport failure or on a non-ok HTTP status. The caller's
 * top-level try/catch is what keeps the hook exiting 0 (NFR-001, ADR-005).
 */
export async function postEvent(backendUrl, event) {
  const ac = new AbortController();
  const timer = setTimeout(() => ac.abort(), ABORT_MS);
  try {
    const res = await fetch(`${backendUrl}/emit`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(event),
      signal: ac.signal,
    });
    if (!res.ok) {
      const httpErr = new Error(`emission POST failed: HTTP ${res.status}`);
      httpErr.name = `http_${res.status}`;
      throw httpErr;
    }
  } finally {
    clearTimeout(timer);
  }
}
