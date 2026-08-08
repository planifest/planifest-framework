#!/usr/bin/env node
/**
 * PostToolUse hook: emit_event receipt writer (req-004, feature 0000027,
 * folded backlog 0000044; ADR-001).
 *
 * Matched (in .claude/settings.json) on the `emit_event` MCP tool call
 * (`mcp__structured-telemetry-mcp__emit_event`). On a successful call, writes
 * a durable local receipt file recording that the call actually happened —
 * closing the failure mode that motivated req-004: feature 0000025's P0-P2
 * run, where the orchestrator marked a build-log `Telemetry` field "emitted"
 * without ever having called `emit_event`, and nothing caught it until a
 * human did.
 *
 * Receipt location: {cwd}/plan/.telemetry-receipts/{phase}-{event_type}-{ts}.marker
 *   (plan/, not .claude/ — durable, git-visible, survives across sessions,
 *   consistent with plan/.telemetry-failures/'s placement rationale).
 *   `{ts}` is the emission timestamp with `:` replaced by `-` — ISO 8601
 *   timestamps contain colons, which are invalid in Windows filenames; every
 *   other marker-writing hook in this family already sanitizes for the same
 *   reason (see recordTelemetryFailure()'s fileSlug conversion in
 *   emit-phase-start.mjs et al.).
 *
 * check-telemetry-receipts.mjs (hooks/enforcement/, sibling to
 * check-telemetry-failures.mjs) cross-references these receipts against
 * build-log.md's per-phase `Telemetry: emitted` claims.
 *
 * Per ADR-001's own risk note: if this hook's own emission/parsing fails
 * (e.g. the MCP tool's argument shape changes), that failure routes through
 * the existing plan/.telemetry-failures/ marker mechanism, exactly like
 * every other telemetry hook in this repo — never a distinct, incompatible
 * failure-reporting path.
 *
 * Always exits 0 — a PostToolUse hook must never block a turn (ADR-005).
 */

import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { join } from "node:path";

function readStdin() {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.setEncoding("utf-8");
    process.stdin.on("data", (chunk) => { data += chunk; });
    process.stdin.on("end", () => resolve(data.replace(/^﻿/, "")));
    process.stdin.resume();
  });
}

// Best-effort durable failure marker — mirrors recordTelemetryFailure() in
// emit-phase-start.mjs/emit-phase-end.mjs/context-pressure.mjs exactly (same
// marker JSON shape, same plan/.telemetry-failures/ location, same
// never-throws contract) so this hook's failures surface through the one
// mechanism check-telemetry-failures.mjs already knows how to read.
function recordTelemetryFailure(hookName, err, context = {}) {
  try {
    const cwd = context.cwd ?? process.cwd();
    const errorType = context.errorType ?? err?.name ?? err?.constructor?.name ?? "Error";
    const errorMessage = String(err?.message ?? err ?? "unknown error");
    const slug =
      errorMessage.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 60) ||
      "unknown";
    const rootCauseKey = `${hookName}::${errorType}::${slug}`;
    const dir = join(cwd, "plan", ".telemetry-failures");
    const fileSlug = rootCauseKey
      .split("::")
      .map((seg) => seg.replace(/[^a-zA-Z0-9_-]+/g, "-").replace(/^-+|-+$/g, "") || "unknown")
      .join("--");
    const markerPath = join(dir, `${fileSlug}.json`);

    mkdirSync(dir, { recursive: true });

    const now = new Date().toISOString();
    let occurrences = 1;
    let firstSeen = now;
    if (existsSync(markerPath)) {
      try {
        const prev = JSON.parse(readFileSync(markerPath, "utf-8"));
        if (typeof prev.occurrences === "number") occurrences = prev.occurrences + 1;
        if (prev.first_seen) firstSeen = prev.first_seen;
      } catch {
        // Corrupt/unreadable prior marker — overwrite fresh below.
      }
    }

    const marker = {
      hook: hookName,
      root_cause_key: rootCauseKey,
      error_type: errorType,
      error_message: errorMessage,
      phase: context.phase ?? null,
      session_id: context.sessionId ?? null,
      first_seen: firstSeen,
      last_seen: now,
      occurrences,
    };

    const tmpMarkerPath = `${markerPath}.tmp`;
    writeFileSync(tmpMarkerPath, JSON.stringify(marker, null, 2));
    renameSync(tmpMarkerPath, markerPath);
  } catch {
    // Marker write is best-effort — never let this throw (ADR-005).
  }
}

function isToolCallError(toolResponse) {
  if (!toolResponse || typeof toolResponse !== "object") return false;
  return toolResponse.is_error === true || toolResponse.isError === true;
}

let cwd;

try {
  const raw = await readStdin();
  const input = JSON.parse(raw);
  cwd = input?.cwd ?? process.cwd();

  if (isToolCallError(input?.tool_response)) {
    // The emit_event call itself failed — there is nothing to receipt. This
    // is exactly the "orchestrator claimed emitted, call didn't happen"
    // shape req-004 exists to catch; leave no receipt so
    // check-telemetry-receipts.mjs flags the gap on its own.
    process.exit(0);
  }

  const envelope = input?.tool_input?.envelope;
  const eventType = envelope?.event;
  const phase = envelope?.phase;

  if (!envelope || !eventType || !phase) {
    // Malformed/unexpected tool_input shape (e.g. the MCP tool's argument
    // contract changed) — record as a failure per ADR-001's own risk note,
    // rather than silently writing nothing with no trace at all.
    throw new Error("emit_event tool_input missing envelope.event or envelope.phase");
  }

  const receiptDir = join(cwd, "plan", ".telemetry-receipts");
  mkdirSync(receiptDir, { recursive: true });

  const timestamp = new Date().toISOString();
  const safeTimestamp = timestamp.replace(/:/g, "-");
  const receiptPath = join(receiptDir, `${phase}-${eventType}-${safeTimestamp}.marker`);

  const receipt = {
    phase,
    event_type: eventType,
    timestamp,
    schema_version: envelope?.schema_version ?? null,
    product_id: envelope?.product_id ?? null,
  };

  const tmpPath = `${receiptPath}.tmp`;
  writeFileSync(tmpPath, JSON.stringify(receipt, null, 2));
  renameSync(tmpPath, receiptPath);
} catch (err) {
  // PostToolUse must never block the session — silent fallback (ADR-005).
  recordTelemetryFailure("emit-event-receipt", err, { cwd });
}
