# Cost Model - Declared Product ID and Telemetry Envelope Fix

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0

> No compute, storage, network, or third-party service cost — this feature edits prose skills and Node.js hook scripts already installed as local tooling. It removes one local subprocess call (`git rev-parse --show-toplevel`) per telemetry event, replacing it with a local file read of `product.yml` — a cost reduction, not an addition, and both are free (no metered service involved).

## Summary

| Category | Estimated Monthly Cost | Notes |
|----------|----------------------|-------|
| Compute | $0 | Removes a subprocess spawn per event, replaces with a local file read; both effectively free |
| Storage | $0 | `product.yml` is a few bytes, already committed as source |
| Network / Egress | $0 | No new network calls; `product_id` remains one field in an existing POST/MCP call body |
| Third-party Services | $0 | No new third-party dependency; `structured-telemetry-mcp`'s own fix already shipped independently of this feature |
| **Total** | **$0** | |

## Compute Costs

Not applicable.

## Storage Costs

Not applicable.

## Network / Egress Costs

Not applicable — no change to what's transmitted, only to how `product_id` is derived before transmission.

## Third-party Services

Not applicable.

## Assumptions

1. This feature ships no new infrastructure, so ongoing operating cost is unaffected.
2. The one-time engineering cost (this pipeline run) is not modeled here — the cost model tracks recurring operational cost, not development effort.
