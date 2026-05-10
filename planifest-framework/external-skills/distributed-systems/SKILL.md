---
name: distributed-systems
description: Distributed systems skill — reason through CAP theorem, consistency models, partitioning strategies, clock synchronisation, and failure modes to design systems that behave predictably under network partition and node failure; use when correctness under partial failure is a hard requirement.
---

# Distributed Systems

You design systems that behave correctly under the failure modes inherent in distributed computing — network partitions, partial node failures, clock drift, and message reordering — without sacrificing the availability or consistency properties the business requires.

## When to Use

- Designing systems that must remain available despite node or network failures
- Choosing between consistency models (strong, sequential, causal, eventual) for a specific use case
- Partitioning data across nodes and choosing partition strategies with their rebalancing implications
- Diagnosing correctness bugs caused by clock drift, message reordering, or split-brain
- Evaluating distributed consensus requirements and when to apply Raft, Paxos, or Zab

## Core Principles

**CAP Theorem Is a Partition Trade-off, Not a Menu.** CAP states that under a network partition, a system must choose between consistency (all nodes return the same data) and availability (all nodes respond to requests). Partition tolerance is not optional in a distributed system — partitions happen. The real choice is: during a partition, do we return stale data (AP) or refuse to respond (CP)? Most databases and systems make this choice per operation type, not globally. Understand which operations in your system require which choice.

**Consistency Models Are a Spectrum, Not a Binary.** Between strong (linearisable) and eventual consistency lie sequential consistency, causal consistency, and read-your-writes consistency. Linearisability guarantees that operations appear to take effect instantaneously at a single point in time — it requires consensus and has a latency cost. Causal consistency guarantees that causally related operations are seen in order by all nodes — weaker than linearisability but achievable without global coordination. Choose the weakest model that satisfies the use case: payment deductions need linearisability; activity feeds tolerate eventual consistency.

**Clocks Lie.** NTP-synchronised clocks on distributed nodes have drift measured in milliseconds to seconds. Two events with timestamps cannot be ordered reliably by comparing timestamps. Use logical clocks (Lamport timestamps) for partial ordering of events in a single causal chain, or vector clocks for tracking causality across concurrent writes on different nodes. Hybrid Logical Clocks (HLC) combine physical time with logical counters to give timestamps that are monotonically increasing and causally consistent — used in CockroachDB and TiDB.

**Failures Are Not Exceptions; They Are the Normal Case.** In a distributed system running at scale, at any moment some node is failing, some network link is congested, some disk is returning errors. Design for failure at every layer: circuit breakers for downstream service calls, exponential backoff with jitter for retries (never fixed-interval retry storms), bulkhead isolation to prevent one failing dependency from exhausting all threads, health checks and automatic node removal for stateful clusters.

**Consensus Is Expensive; Avoid It Where Possible.** Distributed consensus (Raft, Paxos, Zab) requires a majority quorum to commit a write. This introduces latency proportional to round-trip time to the majority and requires at least 2f+1 nodes to tolerate f failures. Use consensus only where required: leader election, distributed locks, configuration management, and strongly consistent metadata operations. Data path writes should use weaker consistency where possible. A Raft-based metadata store coordinating an eventually-consistent data plane is a common and appropriate pattern.

## Approach

Map each operation in your system to a required consistency model. Operations that update financial balances or inventory counts typically require linearisability — use a consensus protocol or a single-node serialised path (with replication for fault tolerance). Operations that update user preferences or activity feeds tolerate eventual consistency — use multi-leader or leaderless replication with conflict resolution.

Choose a partitioning strategy based on access patterns. Hash partitioning (consistent hashing with virtual nodes, as in Cassandra and DynamoDB) distributes data uniformly and enables predictable routing, but range queries require scatter-gather across all partitions. Range partitioning (as in HBase, Bigtable) supports range scans efficiently but creates hot partitions if the key space is not uniformly accessed. Choose based on your dominant query pattern.

Design for split-brain explicitly. In a two-datacenter deployment with a network partition between them, both sides continue operating (AP) and diverge. Reconciliation requires a merge strategy: last-write-wins (LWW) using HLC timestamps, CRDT-based automatic merge (for counters, sets, maps), or human-in-the-loop conflict resolution. LWW loses concurrent writes silently; CRDTs constrain the data model; manual resolution is operationally expensive. Choose the strategy before deploying, not after discovering data corruption.

For distributed transactions, prefer Saga over 2PC. Two-phase commit requires all participants to hold locks until the coordinator commits — a coordinator failure leaves participants in a blocked state. Sagas decompose the transaction into local transactions with compensating actions, accepting eventual consistency for distributed state. For operations that genuinely require atomicity across services (rare), evaluate using a single service as the transaction owner and moving data there, rather than distributed transactions.

Monitor for the distributed systems failure modes that are hardest to detect: partial writes (some replicas received the write, some did not), clock skew causing stale reads to appear current, and retry storms caused by synchronised backoff timers. Implement distributed tracing with trace-context propagation; monitor p99 latency not just mean; alert on replication lag, not just node availability.

## Common Mistakes to Avoid

- **Assuming network calls are reliable.** A service call that does not handle timeout, retry with idempotency, and partial failure is a latent production incident. Every network call needs a timeout; every retry needs an idempotency key.
- **Using wall clocks for event ordering.** Log entries compared by machine timestamp in a distributed system will be ordered incorrectly when clocks drift. Use logical clocks or monotonic sequence numbers from a centralised issuer.
- **Split-brain without a quorum strategy.** A replicated stateful system that does not enforce a quorum write will accept writes on both sides of a partition and produce irreconcilable divergence.
- **Overapplying consensus.** Using Raft-based coordination for every write in a high-throughput data path adds coordination overhead that destroys performance. Consensus belongs on the control plane, not the data plane.
- **Ignoring the thundering herd on retry.** Fixed-interval retry across thousands of clients hitting a recovering service produces a retry storm that prevents recovery. Exponential backoff with random jitter is not optional.

## Output

Distributed systems design output includes: a consistency model matrix per operation type; partitioning strategy with key selection rationale and hot-partition mitigation; replication topology with failure mode analysis; split-brain strategy and conflict resolution mechanism; consensus usage map identifying where consensus is required and what protocol; retry and circuit breaker policy per downstream dependency; and a failure mode catalogue with detection and recovery runbook per failure type.
