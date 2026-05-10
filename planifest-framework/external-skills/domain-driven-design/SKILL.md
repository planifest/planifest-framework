---
name: domain-driven-design
description: Domain-Driven Design skill — apply bounded contexts, aggregates, domain events, and ubiquitous language to model complex domains; use when designing systems where business complexity is the primary driver of architectural decisions.
---

# Domain-Driven Design

You model complex business domains using strategic and tactical DDD patterns, ensuring the software's structure mirrors the domain's actual ownership boundaries and invariants.

## When to Use

- Modelling a domain where business rules are the dominant source of complexity
- Establishing bounded context boundaries before decomposing a system into services
- Designing aggregate roots that enforce invariants without cross-aggregate transactions
- Introducing domain events to decouple bounded contexts
- Aligning team structure to domain ownership using the Strategic Design patterns

## Core Principles

**Ubiquitous Language Is the Foundation.** A ubiquitous language is the shared vocabulary between domain experts and engineers, used consistently in conversations, documentation, and code. When domain experts say "Order" and the code says "PurchaseRecord," the model is already diverging from reality. The language lives within a bounded context — the word "Account" means different things in banking's Risk context and its Customer Management context, and that difference must be explicit, not glossed over.

**Bounded Contexts Define Translation Points.** A bounded context is the boundary within which a model (including its ubiquitous language) is consistent and authoritative. Across a context boundary, models are different and must be translated via a context map. The six relationships on a context map — Shared Kernel, Customer-Supplier, Conformist, Anticorruption Layer, Open-Host Service, Published Language — each carry different coupling and autonomy implications. Choosing the wrong relationship pattern is the primary cause of integration coupling in DDD systems.

**Aggregates Protect Invariants, Not Just Group Data.** An aggregate is a consistency boundary, not a data cluster. The aggregate root is the single transactional entry point. No object outside the aggregate may hold a reference to an interior entity — only to the root. Aggregate size should be minimal: include only what must be consistent within a single transaction. Cross-aggregate consistency is eventual, delivered via domain events. Large aggregates that encompass entire object graphs are a common anti-pattern that destroys concurrency.

**Domain Events Are First-Class Citizens.** A domain event represents something that happened in the domain that other parts of the system (or other bounded contexts) may care about. Events are named in the past tense using domain language: `OrderPlaced`, `PaymentAuthorised`, `ShipmentDispatched`. Events decouple contexts — the Order context emits `OrderPlaced`; the Inventory context reacts to it without the Order context knowing anything about Inventory. Events are also the foundation of Event Sourcing when audit and temporal queries are required.

**Strategic vs Tactical Patterns Serve Different Purposes.** Strategic patterns (bounded contexts, context maps, core/supporting/generic subdomains) tell you what to build and how to organise teams. Tactical patterns (aggregates, entities, value objects, domain services, repositories, factories) tell you how to implement the model within a single context. Many teams apply tactical patterns inside a single monolithic model without strategic decomposition — this produces a "big ball of DDD mud."

## Approach

Begin with strategic design. Run Event Storming sessions with domain experts to discover domain events chronologically, then cluster events into bounded contexts based on ownership, terminology, and rate of change. Identify subdomains: core (differentiating, invest heavily), supporting (necessary but not differentiating, build or buy), generic (commodity, use off-the-shelf). Core subdomain code demands the highest modelling rigour.

Map context relationships explicitly. For each pair of contexts that communicate, choose the integration pattern: Anticorruption Layer (ACL) when you own the downstream and need to isolate it from an upstream model you do not control; Open-Host Service when you are the upstream and want to publish a stable, versioned API; Conformist when you accept the upstream model as-is because the cost of isolation is not justified.

Design aggregates from invariants, not from entities. Ask: what must be consistent at the moment of each command? If `Order` must ensure total value never exceeds credit limit, and credit limit lives on `Customer`, you either need a Saga (eventual consistency) or rethink the aggregate boundary. Aggregates should typically fit in a single database transaction and be loadable in a single repository call. The rule of thumb: prefer small aggregates; start with one entity per aggregate and add only when an invariant demands it.

Model value objects aggressively. Price, Money, EmailAddress, DateRange — these are value objects if they have no identity beyond their value, are immutable, and are compared by value. Making these explicit types rather than primitives (String email, BigDecimal amount) eliminates entire classes of bugs and documents domain concepts in the type system.

Use domain services when an operation does not naturally belong to any aggregate or value object. `TransferService.transfer(sourceAccount, targetAccount, amount)` is a domain service — the operation spans two aggregates and has no natural home on either. Domain services are stateless and named after a domain verb.

## Common Mistakes to Avoid

- **Anemic domain model.** Aggregates that are pure data containers with getters/setters, while all business logic lives in service classes, is not DDD — it is a transaction script with extra vocabulary. Domain logic belongs on the aggregate.
- **God aggregate.** An `Order` that contains `Customer`, `Product`, `Inventory`, `Shipment`, and `Payment` as child entities cannot be updated concurrently and requires loading the entire graph for every operation. Decompose until each aggregate protects exactly one invariant cluster.
- **Applying tactical patterns without strategic design.** Using aggregates and repositories inside a monolithic model with no bounded context decomposition produces complexity without the benefit of isolation. Strategic design first.
- **Using database IDs as aggregate identity across contexts.** A `customerId` from the CRM context should be an opaque reference in the Order context, not a foreign key. Contexts share identifiers, not schemas.
- **Skipping the ubiquitous language.** If the code uses different names than domain experts use, the model is already wrong. The language gap is a model gap.

## Output

DDD design output includes: a subdomain map with core/supporting/generic classification; a bounded context diagram with named context relationships; per-context ubiquitous language glossary; aggregate designs showing roots, entities, value objects, and invariants; domain event catalogue with producer and consumer contexts named; and a context map showing integration patterns between all communicating contexts.
