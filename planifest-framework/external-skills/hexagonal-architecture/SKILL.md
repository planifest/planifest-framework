---
name: hexagonal-architecture
description: Hexagonal (ports-and-adapters) architecture skill — define driving and driven ports, implement technology-specific adapters, and invert dependencies to keep domain logic testable and technology-independent; use when designing systems that must swap infrastructure without touching business logic.
---

# Hexagonal Architecture

You structure systems so the domain model is completely isolated from infrastructure concerns — databases, frameworks, message brokers, and HTTP — by inverting all dependencies at explicit port boundaries.

## When to Use

- Designing a system where the domain model must be testable without any infrastructure
- Building systems that must support multiple delivery mechanisms (HTTP API, CLI, message queue) for the same use case
- Planning to replace or swap infrastructure (e.g., migrate from PostgreSQL to DynamoDB, from REST to gRPC) without touching business logic
- Applying to a legacy codebase where framework concerns have penetrated the domain — refactoring towards hexagonal incrementally
- Enforcing a strict dependency rule across a team where framework leakage is a recurring problem

## Core Principles

**Ports Are Interfaces Owned by the Domain.** A port is an interface declared inside the domain/application layer that expresses what the application needs from the outside world, in domain terms. A driven port (secondary port) might be `OrderRepository` with methods `save(order: Order)` and `findById(id: OrderId): Option<Order>`. It says nothing about SQL, HTTP, or Kafka — those are adapter concerns. The domain owns the port; the adapter implements it.

**Adapters Are Technology Implementations of Ports.** An adapter wires a technology to a port. `PostgresOrderRepository implements OrderRepository` is a driven adapter. `OrderHttpController` is a driving adapter — it calls the application's primary port (`OrderApplicationService`) using HTTP as the delivery mechanism. Adapters live outside the hexagon and depend inward. The domain never depends on an adapter.

**Driving vs Driven Distinction Matters for Testing.** Driving ports (primary) are called by the outside world — they are the application's input surface. Driven ports (secondary) are called by the application — they are the application's output surface. For driving ports, the adapter is a controller/consumer that translates an external protocol into a domain call. For driven ports, the adapter translates a domain call into an external protocol. Driven ports have in-memory test doubles that replace real infrastructure in unit tests.

**Dependency Inversion at the Port Boundary.** The Dependency Inversion Principle is the mechanical engine of hexagonal architecture. High-level modules (domain) define abstractions (ports); low-level modules (adapters) implement them. This means the application layer's tests never instantiate a database — they inject an `InMemoryOrderRepository` that implements the same port interface. The domain compiles and tests run without any infrastructure present.

**Configuration Root Wires Adapters.** The composition root (main method, DI container, test fixture) is the only place that knows both the port and the adapter. It constructs the adapter and injects it into the application service. This is not a framework concern — the hexagon is framework-agnostic. The DI framework is itself an adapter at the composition root.

## Approach

Begin by drawing the hexagon explicitly. The inside contains: domain entities, value objects, domain services, and application services (use cases). Application services implement primary ports and call secondary ports. The outside contains adapters. Draw a strict boundary — no import from outside the hexagon into the inside is permitted.

Define ports before adapters. Write the secondary port interfaces (repositories, message publishers, external service clients) in the domain or application layer, in domain vocabulary. `NotificationPort.notifyOrderShipped(orderId: OrderId, customerId: CustomerId)` — not `EmailService.sendEmail(to: String, subject: String, body: String)`. The port expresses intent; the adapter implements it using the actual email provider.

Implement the simplest adapter first as an in-memory double. Before writing the Postgres adapter, write `InMemoryOrderRepository implements OrderRepository`. This immediately enables unit testing the entire application layer. The Postgres adapter comes later and must pass the same adapter contract tests — a shared test suite that both the in-memory and the real adapter must pass, verifying the port contract.

For driving ports, define them as interfaces that the application service implements. Example: `OrderUseCase` interface with methods `placeOrder(command: PlaceOrderCommand): OrderId`. The HTTP controller calls this interface; it does not instantiate the application service directly. This allows a CLI adapter or a message consumer adapter to call the same use case without any changes to the domain.

Apply the pattern incrementally to legacy code. Identify the most painful infrastructure dependency in the domain (typically a database call or framework annotation inside a business class). Extract a port interface for it. Implement the current behaviour as an adapter. The domain now depends on the abstraction; the test injects an in-memory double. Repeat until the domain is clean.

Enforce the boundary with static analysis. ArchUnit (Java), Dependency Cruiser (Node/TS), or import-linter (Python) can verify that no class in the domain package imports from an adapter package. Make this a CI check — hexagonal architecture enforced only by convention degrades quickly under feature pressure.

## Common Mistakes to Avoid

- **Leaking framework annotations into the domain.** JPA `@Entity` annotations, Spring `@Component`, or ActiveRecord base classes inside domain entities create a hidden adapter dependency. The domain class now requires the framework to compile and run. Use plain domain objects; map to persistence models in the adapter.
- **Ports that mirror adapter APIs.** A port method `saveOrderToDatabase(sql: String)` is not a port — it is a database adapter API leaked upward. Ports speak domain language exclusively.
- **Single-adapter thinking.** If you design a system with exactly one adapter per port and never test-drive a second, the port is probably not abstracted at the right level. A port that cannot be implemented by an in-memory double without violating domain invariants is poorly designed.
- **Composition root in the domain.** The domain must not know which adapter is in use. If the domain instantiates `new PostgresOrderRepository()`, the dependency inversion is broken. Wiring belongs at the composition root only.
- **Fat application services.** Application services should orchestrate use cases — delegate to domain objects, call ports, publish events. Business logic that accumulates in application services is domain logic that has escaped the domain model.

## Output

Hexagonal architecture output includes: a hexagon diagram with named primary and secondary ports; interface definitions for each port in domain vocabulary; adapter list with technology per adapter; a port contract test suite shared by in-memory and real adapters; a static analysis rule set for the domain boundary; and a composition root wiring guide showing which adapter is injected per environment (test, local, production).
