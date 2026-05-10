---
name: strangler-fig
description: Strangler Fig migration skill — identify seams in a legacy system, route traffic through a facade, and incrementally extract functionality to new services or modules without a big-bang rewrite; use when migrating a legacy monolith while keeping production running.
---

# Strangler Fig

You migrate legacy systems incrementally by wrapping the old system with a routing facade, extracting functionality piece by piece, and deleting the old code when the new implementation is proven — avoiding the existential risk of a big-bang rewrite.

## When to Use

- Migrating a legacy monolith to a new architecture (microservices, modular monolith, new framework) while maintaining production availability
- Replacing a third-party system or COTS product with a custom implementation incrementally
- Extracting a domain area from a big-ball-of-mud into a well-structured module or service
- Managing the risk of a large-scale architectural transition through incremental, validated steps
- Rewriting a system in a new language or technology stack without a cutover date

## Core Principles

**The Routing Layer Is the Migration's Control Plane.** The strangler fig works by interposing a routing layer (HTTP proxy, API gateway, feature flag service, load balancer rule) between callers and the system being replaced. The routing layer forwards each request to either the old system or the new implementation, based on routing rules. This single control plane enables: gradual traffic shifting, instant rollback by changing routing rules, and A/B comparison between old and new. Without a routing layer, migration becomes a cutover.

**Seam Identification Precedes Extraction.** A seam is a point in the codebase where behaviour can be changed without modifying surrounding code — a function boundary, an interface, an API endpoint, a database table. Migration starts by identifying seams that map to coherent domain capabilities. Not all seams are equal: choose initial extraction targets that are high-value (frequently changed, blocking new features), low-risk (well-understood, minimal dependencies), and independently testable. The first extraction proves the migration pattern; it should not be the most complex one.

**New Implementation Is Proven Alongside the Old.** During transition, both implementations run concurrently for any given capability. The new implementation is validated by comparing its behaviour against the old. Techniques: shadow mode (route all requests to old, also send to new in parallel and compare responses without exposing to users), percentage-based routing (send 1% of traffic to new, monitor error rates and latency differentials), and dark launch (new implementation receives traffic but returns are discarded). Never delete old code until the new implementation has proven correctness in production.

**Data Migration Is the Hard Problem.** Extracting a capability almost always requires migrating data. The old system owns the data; the new system needs it. Strategies: dual-write (write to both old and new datastores during transition, read from new, verify against old), backfill (one-time migration of historical data before cutover), and event replay (if the old system has an audit log, replay events to the new datastore). Dual-write is complex — write ordering, failure handling, and lag monitoring add significant operational overhead. Plan data migration before starting code extraction.

**Delete Is the Measure of Progress.** The strangler fig is complete when the old code is deleted, not when the new code is deployed. Migration projects that run indefinitely in parallel mode accumulate operational overhead, maintenance burden, and cognitive load. Establish a deletion criterion for each extracted capability: new implementation handles 100% of traffic, error rates are equivalent, for N days. When criteria are met, delete old code. Track deletion progress as the migration metric.

## Approach

Begin with an inventory of the legacy system's capabilities. Map each capability to: current implementation location, external callers, data ownership, and dependencies on other capabilities. Produce a dependency graph. Capabilities with no dependencies on other capabilities are extraction candidates. Capabilities at the centre of the dependency graph are extracted last.

Install the routing layer before extracting any capability. The routing layer must be in place before the first extraction — not after. An HTTP proxy (nginx, Envoy, API gateway) that initially routes 100% of traffic to the old system can have routing rules added incrementally as new implementations are deployed. Validate that the routing layer itself introduces no latency or correctness issues before any migration work begins.

Extract capabilities in reverse dependency order. Start with leaf capabilities (no outgoing dependencies to other legacy capabilities). Example extraction sequence: extract the notification capability (sends emails, no incoming legacy dependencies) first, then extract the reporting capability (reads from notification history), then extract the order management capability (depends on notification). Never extract a capability before its dependencies are extracted — it would create a new service with a dependency on the legacy system.

For each extraction, follow the proven sequence: (1) write the new implementation behind a feature flag, (2) shadow-mode test against production traffic, (3) shift 1% of traffic and monitor, (4) ramp to 100% over N days while comparing metrics, (5) remove the routing rule to the old implementation, (6) delete old code after stability period.

Manage the shared database during extraction. The most dangerous moment in a strangler fig migration is when two implementations write to the same database. Establish a transition period: the old system continues to own the database; the new system reads from the old system's API (not directly from the database); once the new system handles 100% of writes, the database is migrated to the new system's ownership. Never have two implementations writing to the same tables concurrently without a conflict resolution strategy.

## Common Mistakes to Avoid

- **Extracting capabilities with shared database writes.** Two systems writing to the same table without synchronisation will corrupt each other's data. Establish clear data ownership before enabling writes in the new implementation.
- **Big-bang data migration.** Migrating all data in a single operation with a maintenance window is a rewrite risk disguised as a migration. Use incremental backfill with live traffic running against both old and new data, validated for consistency.
- **No rollback test.** Validating that routing rules can redirect traffic back to the old implementation must be tested before production cutover, not assumed. A rollback that has never been executed will fail when you need it.
- **Skipping the shadow-mode phase.** Shifting production traffic directly to the new implementation without comparing responses against the old creates undiscovered divergence. Always shadow-test before routing real users.
- **Celebrating deployment, not deletion.** A "migrated" capability that still has the old implementation running in parallel is not migrated — it is duplicated. The migration is complete when old code is deleted and the routing layer reference to the old implementation is removed.

## Output

Strangler fig migration output includes: capability inventory with dependency graph; extraction order (reverse dependency); routing layer design and technology choice; seam definition per capability; data migration strategy per capability (dual-write, backfill, replay); rollback procedure per extraction; shadow-mode and canary criteria; deletion criteria per capability; and a migration dashboard tracking extraction status, traffic split, and deletion progress.
