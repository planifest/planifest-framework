---
name: modular-monolith
description: Modular monolith skill — design strong module boundaries, shared kernel management, and extraction readiness within a single deployable unit; use when microservices operational overhead is not justified but domain isolation is required.
---

# Modular Monolith

You structure a single deployable unit with module boundaries as strict as service boundaries — enforced at the compiler or build level — so the system remains navigable, independently testable per module, and extractable to services when the economics justify it.

## When to Use

- Building a new system where the domain is not yet well understood and service boundaries would be premature
- Running a team too small to sustain the operational overhead of microservices (roughly fewer than three teams)
- Improving an existing big-ball-of-mud monolith toward a structured architecture as a stepping stone
- Designing a system where single-process deployment is a performance or transactional requirement
- Evaluating whether microservices complexity is justified before committing to extraction

## Core Principles

**Module Boundary Enforcement Must Be Mechanical, Not Conventional.** A module boundary enforced only by code review will be violated by the fifth feature under deadline pressure. Use package visibility controls (Java's module system, Kotlin's `internal`, Python `__all__`, C# `internal`) or build-level encapsulation (Gradle multi-project, Nx libraries, Bazel packages) to make cross-module imports a build failure, not a convention violation. The boundary must be provably enforced.

**Modules Own Their Data, Even in a Shared Database.** The classic modular monolith mistake is sharing a database schema across modules. Two modules reading and writing each other's tables is a distributed monolith without the distribution — coupled at the data layer with no API contract. Each module owns a schema prefix or schema namespace. Cross-module data access goes through the module's public API (in-process function call against a defined interface), not a shared table join.

**The Public API Is the Only Crossing Point.** Each module exposes a narrow public interface — a set of types and functions/methods that other modules may depend on. Everything else is module-private. This contract is stable; internal refactoring is unconstrained. The public API is the seam at which extraction to a service would insert a network call. Design it as if it will be networked, even though it is currently in-process.

**Shared Kernel Must Be Small and Change Slowly.** A shared kernel is code shared between modules: common value objects (Money, UserId), cross-cutting infrastructure (logging, tracing), and possibly shared domain events. The shared kernel must be owned by a joint decision — any change to it requires agreement from all consuming modules. A growing shared kernel is a symptom of poorly drawn module boundaries. If two modules share too much, consider merging them or redesigning the boundary.

**Extraction Readiness Is a First-Class Design Goal.** A module designed for extraction will have: no imports of other modules' internal types (only public APIs), data access isolated to its own schema, a public API that maps naturally to a service API, and no shared mutable in-process state. Design with extraction in mind even if you never extract — it enforces discipline and keeps options open.

## Approach

Map modules to bounded contexts from the domain. Each bounded context becomes a module. The bounded context map (from DDD strategic design) defines the module relationship map: which modules communicate, in which direction, and with what integration pattern. Implement inter-module communication as synchronous in-process calls through defined interfaces, or as in-process domain events through an event bus (with no persistence — events are not durable within the process).

Define the module public API surface explicitly. In Java/Kotlin, use the module-info.java `exports` clause or a dedicated `api` package that is the only publicly accessible package. In TypeScript/Node, use `index.ts` barrel files that re-export only public types. In Python, control `__all__` in `__init__.py`. Do not rely on naming conventions.

Enforce schema isolation with migration tooling. If all modules share a Postgres database, each module uses a dedicated schema (e.g., `orders.*`, `inventory.*`, `payments.*`). Migration scripts are owned per module and never touch another module's schema. A cross-module foreign key is an architectural defect — resolve it by accepting eventual consistency through domain events or by merging the modules.

For cross-module queries that cannot be satisfied by a single module's data (reporting, search), introduce a dedicated read model module that subscribes to domain events from multiple modules and maintains its own denormalised projection. This pattern mimics what would be done with microservices without the network overhead.

Measure coupling continuously. Track the module coupling metric: for each module, how many other modules does it import? A module that imports 10 others is tightly coupled and will be expensive to extract. Track this in CI and treat increases as technical debt that must be paid down before the next major feature.

## Common Mistakes to Avoid

- **Modules defined by technical layer, not domain.** A `services` module, `repositories` module, and `controllers` module that all touch the same domain concepts is not a modular monolith — it is a layered monolith with extra build targets. Modules must align to domain boundaries.
- **Shared database schema across modules.** Direct SQL access from module A to module B's table is the most common violation. It bypasses the API contract entirely and makes extraction impossible without a data migration.
- **In-process event bus without ordering guarantees.** A synchronous in-process event bus that does not guarantee delivery order can produce subtle ordering bugs when multiple modules react to the same event in indeterminate sequence. Define the ordering contract explicitly.
- **Gradual drift toward a big-ball-of-mud.** Module boundaries declared in architecture documents but not enforced in tooling degrade within months. Measure cross-module coupling in CI; fail the build when module access rules are violated.
- **Premature extraction triggered by architecture pressure, not operational need.** Extracting a module to a service before there is a team boundary, a scaling requirement, or a deployment independence need adds operational complexity with no benefit. Extract when there is a proven, concrete driver.

## Output

Modular monolith output includes: module map aligned to bounded contexts; module public API surface definition per module; cross-module communication catalogue (who calls whom, via what interface); data schema ownership matrix; shared kernel inventory with change ownership policy; coupling metric baseline; extraction readiness assessment per module; and build-level enforcement configuration.
