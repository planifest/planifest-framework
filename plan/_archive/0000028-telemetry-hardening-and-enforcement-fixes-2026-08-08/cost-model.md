---
title: "Cost Model - telemetry-hardening-and-enforcement-fixes"
summary: "Compute, storage, egress, and third-party costs, stated honestly at local-tooling scale."
status: "draft"
version: "0.1.0"
---
# Cost Model - telemetry-hardening-and-enforcement-fixes

**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes

## Summary

Essentially zero. This feature changes local subprocess hooks that run on the human on the loop's own
machine. There is no cloud deployment, no managed database, no third-party service beyond the
telemetry backend that already exists and is unmodified by this feature, and no network egress beyond
localhost. The cost model below is short because there is little to model.

## Compute

- **Where it runs:** Node.js subprocesses (`.mjs` hooks) invoked directly by the host tool
  (Claude Code, Cursor, Cline, etc.) on the local machine, per `design.md`'s Engineering Layer.
- **What changes:** req-001 adds a bounded retry loop (2 attempts, 300ms budget) to five hooks, on the
  failure path only. A successful first attempt, the common case, pays no added compute.
- **Cost:** not applicable. No metered compute, no cloud instance, no billed CPU-second. The added cost
  is wall-clock latency, covered under Latency below, not a resource cost.

## Storage

- **What's added:** JSON marker files under `plan/.telemetry-failures/` (existing mechanism, unchanged
  shape) and a new `.marker` receipt file per emitted event under `plan/.telemetry-receipts/` (req-003
  and the gitignore entry for it).
- **Volume:** one small JSON/marker file per distinct failure `root_cause_key` or per emitted event.
  Negligible - low hundreds of bytes each, cleared by the human on the loop as markers are acknowledged
  (see `operational-model.md`).
- **Cost:** local disk only, both directories gitignored so nothing is stored in repo history or any
  remote. Not applicable as a line item; no storage tier, no retention policy needed beyond "the human
  deletes acknowledged markers."

## Egress

- **What crosses the local machine boundary:** a single HTTP POST to `PLANIFEST_TELEMETRY_URL` per
  telemetry event, exactly as today. This feature does not add a new destination or a new call site
  category - it changes retry behaviour around the same existing call.
- **Cost:** not applicable. The telemetry backend is external to this repo and already running
  (verified at P0: listener on `127.0.0.1:3741`), so this is localhost traffic, not metered internet
  egress. No CDN, no cloud load balancer, no data transfer charge of any kind.

## Third-party costs

None. No new SaaS dependency, no new API key, no new paid service. The telemetry backend this feature
retries against is out of scope for modification (per `design.md` constraints) and its own cost, if
any, is unaffected by this feature - this feature only changes how many times the existing hooks retry
before giving up, not what they call or how often a healthy backend is called.

## The only real costs

1. **Added wall-clock latency per hook invocation**, bounded at up to 600ms worst case, and only on the
   failure path (a listener gap that resolves within the retry window, or genuine unavailability before
   the existing 3s per-attempt abort). A successful first attempt is unaffected. See
   `slo-definitions.md` target 1.
2. **Negligible local disk** for markers and receipts, as described under Storage above.

Nothing else in this feature has a cost dimension worth stating. Padding this document with cloud line
items (compute instances, storage tiers, bandwidth pricing) would misrepresent what this feature is.
