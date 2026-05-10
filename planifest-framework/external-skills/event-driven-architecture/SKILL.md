---
name: event-driven-architecture
description: Event-Driven Architecture skill — design event types, choose choreography vs orchestration, handle ordering and idempotency, and evolve event schemas safely; use when designing asynchronous systems or decoupling services via messaging.
---

# Event-Driven Architecture

You design event-driven systems that are loosely coupled, operationally observable, and resilient to partial failure — without sacrificing the ability to reason about system behaviour.

## When to Use

- Decoupling services that currently share synchronous call chains with high fan-out
- Designing workflows that span multiple services and must tolerate partial failure
- Implementing audit logs, integration pipelines, or notification systems
- Replacing polling patterns with reactive push-based processing
- Evolving a system where producers and consumers must deploy independently

## Core Principles

**Event Type Semantics Are Structural Decisions.** Three event types serve distinct purposes: domain events (something happened in the business — `OrderPlaced`), notification events (something changed, go fetch details if you need them — `InventoryUpdated` with no payload), and event-carried state transfer (the event carries enough state for the consumer to act without querying back — `OrderPlaced` with full order data). Choosing the wrong type creates either chatty consumers (notification events where you need full state) or bloated schemas (ECST where consumers only need an ID). The choice determines downstream coupling.

**Choreography Suits Autonomous Reactions; Orchestration Suits Coordinated Workflows.** In choreography, each service listens for events and reacts independently — no central coordinator. Decoupled, resilient, hard to visualise. In orchestration, a central process (Saga orchestrator, workflow engine) issues commands and awaits responses. Observable, easy to monitor and compensate, but the orchestrator becomes a coupling point. Use choreography for simple fan-out reactions; use orchestration when you need to manage compensation logic across many steps, enforce timeouts, or handle partial failure with explicit rollback.

**Ordering Is a Property of a Partition Key, Not a Topic.** Kafka guarantees ordering within a partition, not across a topic. If `OrderCreated` and `OrderCancelled` events for the same order must be processed in sequence, they must land in the same partition — key by `orderId`. Consumers that require global ordering across all events are typically modelling at the wrong granularity. Design partition keys deliberately; never use random keys when ordering matters within an entity's lifecycle.

**Idempotency Is Mandatory.** Event brokers deliver at-least-once. Consumers will receive duplicates — during broker restarts, consumer restarts, and rebalancing. Every consumer must be idempotent: processing the same event twice must produce the same result as processing it once. Implementation options: idempotency keys stored in the consumer's own database; check-and-upsert rather than insert; deduplication tables with a TTL. Idempotency is not optional — it is the contract between broker and consumer.

**Schema Evolution Must Be Backwards Compatible.** Producers and consumers deploy independently. A producer deploying a new event schema version must not break existing consumers. Rules: fields may be added with defaults; fields may not be removed or renamed without a deprecation period; field types may not change. Use a schema registry (Confluent Schema Registry, AWS Glue Schema Registry) with compatibility modes enforced (BACKWARD, FORWARD, FULL). Event versioning strategies — embedding version in the event type name (`OrderPlaced.v2`) vs using a schema registry version — each have operational trade-offs.

## Approach

Begin by mapping the event flow before choosing technology. Draw a producer/consumer matrix: for each event type, who emits it, who consumes it, what they do with it, and what ordering and delivery guarantees they require. This matrix surfaces fan-out (one producer, many consumers), fan-in (many producers, one consumer), and ordering dependencies.

Choose the broker based on requirements. Kafka/Pulsar for durable, replayable, ordered event streams with high throughput; ordered delivery per partition; long retention for event sourcing or replay. RabbitMQ/SNS+SQS for task queues, routing, and fan-out where ordering is not critical and per-message TTL or DLQ routing is needed. Managed services (EventBridge, Pub/Sub) for serverless integration patterns. Do not choose Kafka because it is popular — its operational complexity is significant and unjustified when ordering and replay are not requirements.

Design the dead letter queue (DLQ) strategy before going live. Every consumer queue needs a DLQ with alerting. A message in a DLQ is a business event that was not processed — it is not a metric to ignore. DLQ messages require: operator visibility, runbooks for common failure types, and a replay mechanism to reprocess once the root cause is fixed. Consumer poison-pill handling (a malformed event that always fails) requires a skip mechanism with audit logging.

For workflow coordination, use the Saga pattern. A saga is a sequence of local transactions, each publishing an event that triggers the next step. If a step fails, compensating transactions undo prior steps. Choreography sagas have no central coordinator — each service knows what to emit on success and on failure. Orchestration sagas use a saga orchestrator that tracks state and issues commands. For workflows with more than four or five steps, or with complex compensation logic, orchestration sagas are significantly easier to operate and debug.

Event schema governance requires a registry and review process. Treat event schemas as public APIs — once published, they have consumers you may not control. Establish a schema review gate before any event schema is promoted to production. Schema changes undergo the same review process as API changes.

## Common Mistakes to Avoid

- **Fire-and-forget without DLQ.** An event that fails processing silently is a data loss event. Every consumer must have a DLQ, alerting, and a replay path.
- **Using events as synchronous RPC.** Sending a command event and blocking on a response event is synchronous RPC with extra latency and complexity. Use actual RPC for synchronous needs.
- **Putting commands in event topics.** Events are facts; commands are requests. An `OrderService.PlaceOrder` command event that only one consumer should process is not an event — it is a message queue. Model this as a command, not an event.
- **No event versioning strategy.** Evolving event schemas without a version contract breaks consumers in production. Establish compatibility rules before the first consumer exists.
- **Choreography for complex workflows.** A 10-step fulfilment saga implemented in pure choreography is a debugging nightmare. When each service must know which event to emit on its own failure to trigger compensation in upstream services, the implicit workflow model becomes incoherent. Use an orchestrator.

## Output

EDA design output includes: a producer/consumer event matrix; event catalogue with type (domain/notification/ECST), schema, partition key, retention, and ordering requirements per event; broker selection with rationale; DLQ strategy per consumer; idempotency implementation per consumer; schema evolution policy; and for any multi-step workflow, a saga design with compensation transaction map.
