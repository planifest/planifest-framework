---
name: saga-pattern
description: Saga pattern skill — design choreography and orchestration sagas with compensation transactions for distributed workflow failures; use when a business operation spans multiple services and distributed ACID transactions are not viable.
---

# Saga Pattern

You design long-running distributed workflows that maintain business consistency across multiple services through local transactions and compensating actions, accepting eventual consistency rather than requiring distributed locks or two-phase commit.

## When to Use

- A business workflow spans multiple services, each with its own database, and must remain consistent even when individual steps fail
- Two-phase commit is ruled out due to availability requirements (2PC blocks on coordinator failure), performance requirements, or service autonomy
- A business process has natural rollback semantics — cancelling an order undoes reservation and refunds payment
- Implementing order-to-cash, booking, or fulfilment workflows in a microservices system
- Designing idempotent retry behaviour for workflows that may partially execute before failure

## Core Principles

**Sagas Achieve ACD Without I.** Sagas provide Atomicity (either all steps complete or compensations undo completed steps), Consistency (each local transaction maintains its service's invariants), and Durability (each local transaction is durable). They do not provide Isolation — intermediate saga states are visible to other operations. A concurrent query may observe an order in a partially-fulfilled state. If the business cannot tolerate this intermediate visibility, design countermeasures: semantic locks (mark the record as being-processed), or accept the visibility and design the UI around it.

**Compensation Is Not Rollback.** A compensating transaction does not undo a database transaction — that transaction has already committed and may have triggered downstream effects. A compensation creates a new transaction that logically reverses the effect. `ReserveInventory` is compensated by `ReleaseInventoryReservation`. `ChargePayment` is compensated by `RefundPayment`. Not every step needs a compensation — a step that has no externally visible effect (a read, a calculation) is simply abandoned. Design compensations as idempotent operations.

**Choreography Sagas Couple Through Events.** In a choreography saga, each service listens for events and reacts by executing a local transaction and emitting a new event. No central coordinator exists — the saga's workflow is implicit in the event flow. Benefits: no single point of failure, maximum service autonomy. Drawbacks: the overall workflow is distributed across multiple services and is difficult to visualise, monitor, and debug. Choreography works well for simple workflows (3-4 steps) and is increasingly difficult to reason about as complexity grows.

**Orchestration Sagas Centralise Workflow State.** An orchestration saga has a dedicated orchestrator (saga manager, process manager) that tracks workflow state and issues commands to services. The orchestrator receives responses (success or failure events), decides what to do next, and persists its own state durably. Benefits: the workflow is explicit, visible, and monitorable in one place; compensation sequencing is straightforward; timeouts and retries are managed centrally. The orchestrator is a logical coupling point but not a deployment bottleneck — it does not process requests synchronously.

**Idempotency at Every Step Is Mandatory.** Sagas retry steps that time out or fail. Every service operation invoked by a saga must be idempotent — executing the same command multiple times must produce the same result. Implement idempotency keys: the orchestrator assigns a unique idempotency key per saga step, the service stores the key with the result, and duplicate requests return the stored result without re-executing. Without idempotency, a saga retry causes double-charging, double-shipping, or double-reservation.

## Approach

Map the happy path first. Draw the sequence of local transactions: reserve inventory → charge payment → create shipment → notify customer. Each step is owned by exactly one service. Each step succeeds or fails — no partial success within a step.

Define compensations for each reversible step. Work backwards from the last step. For each step that has external effects, define the compensation operation and verify it is idempotent. Document which steps have no compensation (purely internal, no external effects — simply abandoned on failure). Produce a compensation table: step → compensating step → idempotency semantics.

Choose choreography or orchestration based on workflow complexity and team ownership. Use choreography when: fewer than four steps, each step is independently deployable and owned by a different team, the event flow is the natural communication style. Use orchestration when: five or more steps, complex conditional branching (if payment fails due to fraud vs insufficient funds, compensate differently), timeout requirements on individual steps, or when workflow visibility is required for operations and support teams.

For orchestration, design the saga orchestrator's state machine explicitly. States: `STARTED`, `INVENTORY_RESERVED`, `PAYMENT_CHARGED`, `SHIPMENT_CREATED`, `COMPLETED`, `COMPENSATING`, `COMPENSATION_COMPLETED`, `FAILED`. Transitions are driven by success/failure events from services. The state machine must handle: duplicate events (idempotent transitions), out-of-order events (may arrive from retried steps), and timeout transitions (if no response in N seconds, transition to compensation path).

Persist orchestrator state durably before sending each command. The pattern is: persist state transition → send command. If the orchestrator crashes after persisting but before sending, the command is sent on restart. If it crashes after sending but before the response, the response is processed on restart. This sequence ensures the orchestrator never loses track of where it is in the workflow.

Handle concurrent sagas on the same entity. Two simultaneous order sagas that both try to reserve the last unit of inventory will conflict. Semantic locks (mark inventory as `being-reserved` before the saga step begins, release on completion or compensation) prevent this. Alternatively, use optimistic locking with version numbers and let the second saga fail and compensate.

## Common Mistakes to Avoid

- **Non-idempotent saga steps.** Retrying `ChargePayment` without an idempotency key results in double-charging. Every external call from a saga step must carry an idempotency key derived from the saga ID and step name.
- **Compensations that assume state they do not own.** A compensation for Step 3 that assumes Step 2's state is still as it was when Step 2 executed may be operating on stale or modified data. Compensations must fetch current state and act idempotently against it.
- **Choreography for complex workflows.** A 10-step saga in pure choreography distributes the workflow across 10 services. When a compensation must execute, each service must know which event to emit to trigger the upstream compensation — creating hidden coupling. Use orchestration for complex or long-running workflows.
- **Orchestrator as a synchronous API.** An orchestrator that blocks waiting for saga completion on every user request is a latency bottleneck. Sagas are asynchronous by nature — accept the saga, return a saga ID, and let the client poll or subscribe for completion.
- **No timeout handling.** A saga step that never responds leaves the orchestrator waiting indefinitely. Every step must have a timeout; the orchestrator must transition to a compensation path when the timeout fires.

## Output

Saga design output includes: happy path step sequence with service owner per step; compensation table (step, compensating step, idempotency strategy); orchestration state machine diagram with all states and transitions; timeout policy per step; idempotency key scheme; concurrent saga conflict resolution strategy; orchestrator persistence design; and observability plan (saga state dashboard, stale saga alerting).
