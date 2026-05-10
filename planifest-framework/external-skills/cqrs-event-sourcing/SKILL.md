---
name: cqrs-event-sourcing
description: CQRS and Event Sourcing skill — separate command and query models, design an event store, build projections, and reason through eventual consistency trade-offs; use when audit requirements, temporal queries, or read/write scaling asymmetry drive the design.
---

# CQRS + Event Sourcing

You design systems where writes produce immutable domain events stored as the source of truth, and reads are served by purpose-built projections optimised for specific query patterns — accepting the operational complexity this entails in exchange for auditability, temporal flexibility, and read scalability.

## When to Use

- Regulatory or audit requirements demand a complete, immutable history of state changes
- Read and write access patterns are radically asymmetric — complex, high-volume queries vs. low-volume, invariant-enforcing writes
- Temporal queries are required — "what was the state of this aggregate at time T?"
- Debugging production issues requires the ability to replay events to reproduce state
- Multiple read models of the same data are needed for different consumers (reporting, search, mobile API)

## Core Principles

**The Event Store Is the System of Record.** In Event Sourcing, the database does not store current state — it stores a sequence of domain events. Current state is derived by replaying events from the beginning (or from a snapshot). `OrderPlaced`, `ItemAdded`, `PaymentAuthorised`, `OrderShipped` are the facts; the current `Order` state is a view. This means you never lose history — you cannot `UPDATE orders SET status = 'shipped'` and lose the fact that it was previously `pending`.

**Commands Validate Against Current State; Events Record What Happened.** A command is an intent (`PlaceOrder`). The aggregate loads its current state by replaying its event history, validates the command against invariants, and if valid, produces one or more events (`OrderPlaced`). The command may be rejected — the event cannot. Events are facts in the past tense; they are never rejected once emitted. This asymmetry is fundamental: the write side enforces invariants, the event log records truth.

**Projections Are Disposable.** A projection (read model) is built by subscribing to the event stream and maintaining a queryable view. Because the event store is the source of truth, a projection can always be rebuilt from scratch by replaying all events. This makes projections disposable — if a bug corrupts a projection, rebuild it. This property is only valuable if replay is operationally fast; design the event store for efficient sequential reads by aggregate ID and by global position.

**CQRS Without Event Sourcing Is Viable; Event Sourcing Without CQRS Is Painful.** CQRS — separate command (write) and query (read) models — can be applied to any persistence strategy, not only Event Sourcing. Many systems benefit from CQRS with a conventional relational write side and a denormalised read side. Event Sourcing almost always implies CQRS, because serving queries directly from event replay is too expensive for most read patterns. Apply them independently based on actual requirements, not as a package deal.

**Eventual Consistency Is the Default Contract.** A command succeeds when the event is appended to the event store. The projection that reflects this command's effect may not be updated immediately. Clients must design around this: a UI that shows the "just placed" order may read a stale projection for a few hundred milliseconds. This is not a bug — it is the consistency model. Make it explicit in the API contract; implement read-your-writes at the query layer only when the UX demands it (e.g., return the command result directly, bypass the projection for the immediate response).

## Approach

Design the event store schema before the domain model. An event store has two access patterns: load all events for a given aggregate ID (ordered by sequence number), and subscribe to all events ordered by global sequence position. A simple relational event store table: `(aggregate_id, sequence_number, event_type, payload, occurred_at, metadata)` with a unique constraint on `(aggregate_id, sequence_number)`. The global position is a separate auto-increment column or a separate append log. EventStoreDB is a purpose-built option; Kafka with compaction serves some use cases; a Postgres-backed event store with Outbox pattern is a pragmatic starting point.

Model aggregates as event-sourcing aggregates explicitly. The aggregate has two operations: `apply(event)` which mutates state, and `handle(command)` which validates and returns events. The `apply` method is called both during reconstitution (replaying history) and after a new command produces events. State held by the aggregate is only what is needed to validate future commands — not what read models need.

Implement snapshotting for long-lived aggregates. Replaying 100,000 events to reconstitute an aggregate for every write is unacceptable. Snapshot at a threshold (e.g., every 100 events): serialise current state alongside the sequence number. On load, fetch the latest snapshot, then replay only events after the snapshot sequence. The snapshot is a performance optimisation — it can always be discarded and rebuilt.

Design projections as independent subscribers. Each projection subscribes to the global event stream from a stored position. On restart, it resumes from its last processed position. The projection owns its own database (or schema, or table prefix) — it is not shared with the write side. Multiple projections can consume the same event stream independently and at different rates. A failing projection does not affect the write side.

For optimistic concurrency, use expected version. When appending events for an aggregate, supply the expected sequence number. If another writer has appended since the aggregate was loaded, the append fails with a concurrency conflict — the command handler retries. This is the Event Sourcing equivalent of optimistic locking and avoids distributed locks.

## Common Mistakes to Avoid

- **Storing current state in events.** An event like `OrderUpdated { currentStatus: "shipped", currentTotal: 299.99 }` is not a domain event — it is a state snapshot masquerading as an event. Events must capture what changed and why: `OrderShipped { shipmentId, carrier, trackingNumber }`.
- **Rebuilding projections from the application layer.** Projection rebuild must be a background operation that reads from the event store directly, not a sweep that calls application services in a loop. Running commands to rebuild state corrupts the event log.
- **Ignoring upcasting.** Event schemas change. An event stored three years ago may no longer deserialise against the current schema. Implement upcasters — transformations applied during deserialisation — rather than mutating stored events.
- **One projection to rule them all.** A single "canonical" projection that serves every query shape becomes a God table. Design narrow projections for specific read models: one for the order list screen, one for the order detail screen, one for the fulfilment dashboard.
- **No position tracking in projections.** A projection that does not persist its last-processed position will replay all events from position zero on every restart. At scale, this becomes a catastrophic startup time.

## Output

CQRS + ES design output includes: event store schema with append and subscribe access patterns; aggregate event catalogue with event schema per event type; command/event mapping per aggregate; projection catalogue with query pattern per projection and database technology; snapshotting strategy; concurrency control mechanism; projection rebuild runbook; and a consistency model document explaining the eventual consistency contract to API consumers.
