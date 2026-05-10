---
name: c4-diagramming
description: C4 model diagramming skill — produce context, container, component, and code-level diagrams with correct notation, appropriate scope per level, and tooling choices that keep diagrams current; use when communicating architecture to audiences with different levels of detail requirement.
---

# C4 Model Diagramming

You produce architecture diagrams at the right level of abstraction for each audience — from the board-level system context to the developer-level component wiring — using the C4 model's disciplined notation.

## When to Use

- Communicating system structure to stakeholders with different technical backgrounds simultaneously
- Onboarding engineers to a codebase by showing them the system's container and component structure before they read code
- Documenting an architecture decision in an ADR with a supporting diagram
- Reviewing a proposed design by walking through each level of the C4 hierarchy
- Producing living documentation that is maintainable alongside the codebase

## Core Principles

**Each Level Has a Defined Audience and Abstraction.** Level 1 (Context): shows the system in its environment — external users and external systems. Audience: non-technical stakeholders, product owners, newcomers. Level 2 (Container): shows deployable units inside the system — web apps, APIs, databases, message queues. Audience: architects, senior engineers, operators. Level 3 (Component): shows the major structural components inside a single container. Audience: developers working on that container. Level 4 (Code): shows the internal implementation — classes, interfaces, modules. Audience: developers implementing a specific component. Never conflate levels; a context diagram that shows database tables is wrong.

**Every Element Needs Name, Type, and Description.** A box on a C4 diagram has: a name (what it is), a technology/type annotation (e.g., "React SPA", "PostgreSQL 15", "Kafka topic"), and a short description (what it does in one sentence). Diagrams with unlabelled boxes or missing technology annotations are ambiguous. A container diagram showing "Database" with no technology annotation does not communicate whether it is relational, document, or graph — this matters to every audience.

**Relationships Must Name the Protocol and Intent.** An arrow between elements has: a label describing what is communicated ("places orders via"), and a technology annotation ("HTTPS/REST" or "Kafka event"). A bare arrow says nothing — it only says "there is a connection." The label and technology annotation distinguish: "reads from" vs "writes to", "subscribes to events from" vs "publishes commands to", "authenticates users against" vs "queries product data from."

**Diagrams Are Not the Source of Truth — Code Is.** A diagram that diverges from the running system is worse than no diagram — it actively misleads. Use diagram-as-code tools (Structurizr DSL, Mermaid C4, PlantUML with C4 macros) so diagrams live in version control alongside code. Automate extraction where possible: C4 context and container diagrams can be derived from infrastructure-as-code (Terraform, Kubernetes manifests) using tooling. Review diagram accuracy as part of architecture reviews.

**Scope Each Diagram to One Question.** A container diagram that shows all 40 containers in a microservices system with all their relationships is unreadable. Scope each diagram to answer one architectural question: "How do users interact with the checkout flow?" "Which containers own payment data?" "How does the notification subsystem connect to the rest of the system?" A focused diagram communicates; an all-encompassing diagram decorates.

## Approach

Start with the Level 1 (System Context) diagram. Identify: the system being described (a single box), the human users who interact with it (people icons), and the external systems it integrates with (external system boxes). For each relationship, name the interaction. This diagram must be comprehensible to a non-technical reader in under two minutes. If it is not, it has too much detail.

For each Level 2 (Container) diagram, list all deployable units: web front ends, mobile apps, API services, background workers, databases, caches, message brokers, CDN, blob storage. Group by runtime boundary — a Docker container, a Lambda function, a VM, a Kubernetes pod are all "containers" in C4 terms. Show only the containers; do not show internal component structure at this level.

For Level 3 (Component) diagrams, scope to a single container. Identify the major components inside it — architectural-level components, not every class. In a typical service: controllers/handlers, application services/use cases, domain model, repositories, clients for external services. Show how an inbound request flows through the component structure. One component diagram per container; produce only the containers that have interesting internal structure worth documenting.

Level 4 (Code) diagrams are rarely worth maintaining. They go stale immediately as code evolves and provide less value than reading the code. Reserve Level 4 for documenting a particularly complex algorithm or pattern that cannot be communicated in prose.

For tooling, prefer diagram-as-code. Structurizr DSL is the reference implementation — it enforces the C4 model, supports all four levels, generates multiple diagram views from a single model, and produces a searchable workspace. For lightweight use, Mermaid C4 diagrams embedded in markdown files in the repository are maintainable by developers without a separate tool. Avoid drawing-tool diagrams (Visio, Lucidchart, draw.io) for architecture documentation — they diverge from reality immediately and are not reviewable in pull requests.

## Common Mistakes to Avoid

- **Mixing levels on a single diagram.** A container diagram that shows one container's internal components alongside other containers' external interfaces confuses levels and audiences. Each diagram is exactly one level.
- **Technology-free diagrams.** Boxes without technology annotations ("Web App" rather than "React 18 SPA, served via CloudFront") fail to communicate the architectural decisions. Technology choice is part of the architecture.
- **Relationship arrows without labels.** An unlabelled arrow between a service and a database says nothing about read vs write, synchronous vs asynchronous, or what data is involved. Label every relationship.
- **All-system container diagrams.** A single container diagram with 30+ containers and 100+ relationships is a hairball, not communication. Scope container diagrams by domain area or user journey.
- **Diagram-in-a-wiki without version control.** A diagram stored in Confluence or a shared drive diverges from the codebase within weeks. Diagrams must live in version control, reviewed alongside code changes that affect the architecture they depict.

## Output

C4 diagramming output includes: one Level 1 (Context) diagram for the whole system; Level 2 (Container) diagrams scoped by domain area or user journey; Level 3 (Component) diagrams for architecturally significant containers only; tooling choice with version-control integration plan; diagram-as-code files checked into the repository; and a diagram review cadence integrated into the architecture review process.
