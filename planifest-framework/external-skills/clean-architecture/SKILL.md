---
name: clean-architecture
description: Clean Architecture skill — apply the dependency rule to organise entities, use cases, interface adapters, and frameworks into concentric layers where inner layers have zero knowledge of outer layers; use when framework independence and long-term modifiability are architectural drivers.
---

# Clean Architecture

You organise systems so that business rules are isolated from delivery mechanisms and infrastructure, making the system testable, framework-independent, and modifiable without ripple effects across layers.

## When to Use

- Building systems where framework or database replacement must not require rewriting business logic
- Establishing a layered structure that enforces dependency direction — inner rings never depend on outer rings
- Designing use cases as the primary unit of behaviour, not controllers or database models
- Refactoring legacy applications where framework concerns have colonised business logic
- Defining the architectural standard for a team where layering discipline is required

## Core Principles

**The Dependency Rule Is Absolute.** Source code dependencies may only point inward. Entities (innermost) know nothing of use cases; use cases know nothing of interface adapters; interface adapters know nothing of frameworks and drivers. The innermost ring knows nothing about the existence of outer rings. This is not a preference — it is the mechanical constraint that makes the rest of the architecture work. Any violation of the dependency rule is an architectural defect.

**Entities Encode Enterprise Business Rules.** Entities are the most stable, most reusable objects in the system. They encode business rules that would exist regardless of whether you were running a web app, a CLI, or a batch job. An `Order` entity with its invariants (line items must have positive quantities, total must match sum of items) is an entity. It does not know about HTTP, databases, or frameworks.

**Use Cases Encode Application Business Rules.** Use cases (also called interactors) contain the application-specific business rules — the rules that would change if the application's purpose changed, even if the enterprise rules stayed the same. `PlaceOrderUseCase` knows: it receives a `PlaceOrderRequest`, calls the `OrderRepository` port to check inventory, constructs an `Order` entity, saves it via the `OrderRepository` port, and returns a `PlaceOrderResponse`. It knows nothing about HTTP, JSON, or SQL.

**Interface Adapters Translate Between Use Cases and External Formats.** Controllers, presenters, and gateways live here. An HTTP controller translates an HTTP request into a `PlaceOrderRequest` DTO and calls the use case. A presenter translates the `PlaceOrderResponse` into a JSON response body. A repository gateway implements the `OrderRepository` port using SQL. None of these objects contain business logic — they are pure translation.

**Frameworks and Drivers Are Details.** The web framework, the ORM, the message broker client, the test framework — these are outermost ring details. The system's architecture is defined by the inner rings; the outer rings are plug-in implementations. A clean architecture can swap Spring for Quarkus, PostgreSQL for MongoDB, or REST for gRPC by replacing outer-ring adapters without touching entities or use cases.

## Approach

Draw the concentric rings first. Inner to outer: Entities, Use Cases, Interface Adapters, Frameworks and Drivers. Every file in the codebase belongs to exactly one ring. Every import statement in a file must point inward or stay within the same ring. Enforce this with a static analysis tool before writing the first line of code.

Define use case boundaries by input/output DTOs. Each use case has a request DTO (plain data object, no behaviour) and a response DTO. The use case method signature: `execute(request: PlaceOrderRequest): PlaceOrderResponse`. The request and response DTOs live in the use case ring — they are not the entity, and they are not the HTTP model. This double-mapping (HTTP model → request DTO → entity, entity → response DTO → HTTP model) is the cost; the benefit is that the use case compiles and tests without any web framework.

Implement the Repository pattern as a use case ring interface. `OrderRepository` is declared in the use case ring with methods the use case needs. The SQL implementation lives in the frameworks ring, implementing this interface. The use case depends on the interface; the DI container injects the implementation. This is Dependency Inversion applied mechanically.

The Presenter pattern is often neglected. Rather than returning a response DTO from a use case and having the controller format it, Robert Martin's formulation passes a presenter (output boundary) to the use case, which calls `presenter.present(response)`. This inverts even the output dependency. In practice, most teams use the simpler approach — use case returns a response DTO — and this is an acceptable trade-off for most applications. Use the presenter pattern only when output formatting is complex or multiple delivery mechanisms need different formats for the same use case.

Test use cases in isolation. Use case unit tests inject in-memory implementations of all repository and service ports. The tests run in milliseconds with no database, no web server, no message broker. Integration tests test the adapters — the SQL repository implementation against a real database, the HTTP controller against a real web server. Keep the test pyramid: many use case unit tests, fewer adapter integration tests, minimal end-to-end tests.

## Common Mistakes to Avoid

- **Putting business logic in controllers.** An HTTP controller that validates input, applies business rules, and directly calls a database is not Clean Architecture — it is a transaction script. Business rules belong in entities and use cases, not in delivery layer objects.
- **Using ORM entities as domain entities.** Annotating domain entities with JPA/Hibernate annotations creates a dependency from the entity ring to the frameworks ring — a direct inversion violation. Use separate persistence models in the adapter layer and map between them.
- **Skipping the use case layer.** Controllers calling repositories directly with no use case layer eliminates the application's ability to have delivery-mechanism-independent business rules. Use cases are not optional boilerplate — they are the system's specification in code.
- **Shared DTOs across rings.** Using the HTTP request model as the use case request DTO couples the use case to the HTTP contract. When the API changes, the use case changes. Each ring has its own data model.
- **Flat package structure despite layered intent.** Naming packages `models`, `services`, `repositories` does not enforce the dependency rule — it is a layer-by-technical-role structure. Package by ring: `entities`, `usecases`, `adapters.web`, `adapters.persistence`, `frameworks`.

## Output

Clean Architecture output includes: ring assignment for every major component; use case catalogue with input/output DTO signatures; repository and service port interfaces in the use case ring; adapter list with technology per adapter; static analysis rule configuration for the dependency rule; and a test strategy showing which tests cover which ring with isolation levels.
