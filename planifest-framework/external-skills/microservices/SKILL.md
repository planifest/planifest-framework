---
name: microservices
description: Microservices design skill — define service boundaries using domain cohesion, own data per service, choose inter-service communication patterns, and manage operational complexity; use when decomposing a system or evaluating whether microservices fit.
---

# Microservices

You design service boundaries that align with domain ownership, not technical layers, and manage the operational overhead that decomposition introduces.

## When to Use

- Decomposing a monolith where teams own distinct domains and need independent deployment
- Evaluating whether microservices are the right architectural style for a given context
- Designing data ownership and communication contracts between services
- Diagnosing coupling problems — chatty services, shared databases, blast-radius incidents
- Defining the operational platform requirements a microservices system demands

## Core Principles

**Service Boundary = Domain Boundary.** The correct unit of decomposition is a bounded context, not a technical concern. An "Auth service" that is called by 40 other services is a distributed monolith's dependency graph wearing a microservices label. Services should model a domain capability — Order Management, Fulfilment, Pricing — and expose it through a stable API. When the boundary is wrong, coupling shows up as chatty inter-service calls and coordinated deployments.

**Data Ownership Is Non-Negotiable.** Each service owns its data store exclusively. No service reads another service's database directly — not for convenience, not for performance. Shared schema = shared deployment coupling. The pattern for cross-service data access is: async event propagation (service B maintains a local read model of data from service A) or synchronous API (service B calls service A's API). Violating this makes the "independently deployable" promise false.

**Communication Style Matches Coupling Tolerance.** Synchronous REST/gRPC is appropriate when the caller needs an immediate, authoritative response and can tolerate the called service being unavailable. Asynchronous messaging (Kafka, RabbitMQ, SNS+SQS) decouples availability but introduces eventual consistency and requires idempotent consumers. Choosing synchronous vs async is not a preference — it follows from latency requirements and acceptable coupling.

**Operational Platform Is a Prerequisite, Not a Follow-on.** Microservices require: distributed tracing (Jaeger, Tempo), centralised log aggregation, health endpoints on every service, container orchestration, service discovery, and ideally a service mesh for mTLS and traffic management. Teams that adopt microservices without this platform spend all their time debugging distributed failures. The platform must be ready before decomposition, not after.

**Extract on Proven Seam, Not Anticipated Seam.** A seam that looks clean in a design document often turns out to be wrong once real traffic reveals actual access patterns. Extract to a service only when the seam is stable, the domain boundary is proven, and independent deployability or scalability genuinely justifies the operational overhead.

## Approach

Start by questioning whether microservices are appropriate. The decision hinges on: team structure (Conway's Law — services mirror team boundaries), deployment frequency requirements (do teams need to deploy independently?), and scale characteristics (do different domains have radically different scaling needs?). A 5-person team building a CRUD application rarely benefits from microservices; a 200-person organisation with 10 product teams typically does.

Define service boundaries using Event Storming or Domain Storytelling. Map the domain through events first, then identify where events cross ownership boundaries — those crossings are service boundaries. Key signal: if a single business operation requires coordination across more than two or three services, the boundary is wrong.

Model inter-service communication explicitly. Produce a service dependency graph. Cycles in the graph indicate boundary errors. High fan-in to a single service (many callers) signals that the service is a distributed singleton — a scalability and availability bottleneck. Services with many synchronous outbound calls (high fan-out) are vulnerable to cascading failures and need circuit breakers (Hystrix, Resilience4j) or bulkhead isolation.

For data consistency across services: prefer eventual consistency delivered via domain events. When strong consistency is required across boundaries (rare), evaluate the Saga pattern rather than distributed transactions (2PC is operationally fragile and couples services at the protocol level). Accept that some queries require a read model assembled from multiple services' events — a CQRS projection or a dedicated query service.

Version service APIs deliberately. Semantic versioning of API contracts. Consumer-driven contract tests (Pact) verify that a service change does not break existing consumers before deployment. Never remove a field from a published API without a deprecation period. Additive changes are backwards-compatible; subtractive changes are breaking.

## Common Mistakes to Avoid

- **Shared database across services.** Convenience defeats independence. Two services sharing a schema cannot be deployed or evolved independently. Extract to API or event before extraction to service.
- **Decomposing by technical layer.** A "data service," "business logic service," and "UI service" that always deploy together and share state is a monolith with network latency inserted between layers.
- **Synchronous chain depth.** A user request that traverses five synchronous hops has a latency floor of the sum of all five and fails if any one is unavailable. Flatten synchronous chains; push orchestration to a saga or move to async.
- **Ignoring the distributed tracing prerequisite.** Without trace IDs propagated across all services and a trace aggregation backend, debugging production issues becomes guesswork. This is not optional.
- **Premature decomposition.** Extracting services before the domain model is stable means the wrong seams become hard API boundaries. Build the monolith first, prove the seams, then extract.

## Output

Service decomposition output includes: a bounded context map identifying service ownership; a service dependency graph (directed, checked for cycles); a communication pattern decision per service pair (sync vs async, with rationale); a data ownership matrix; and an operational platform checklist. Each service has a defined API contract (OpenAPI or AsyncAPI) and a consumer-driven contract test suite.
