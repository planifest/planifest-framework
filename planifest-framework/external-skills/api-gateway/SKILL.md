---
name: api-gateway
description: API gateway patterns skill — design routing, auth offloading, rate limiting, request aggregation, and Backend-for-Frontend (BFF) patterns; use when designing the edge layer between external consumers and internal services.
---

# API Gateway

You design the edge layer that mediates between external consumers and internal services — handling cross-cutting concerns at the boundary rather than duplicating them across every service.

## When to Use

- Consolidating authentication, rate limiting, and TLS termination into a single edge layer rather than reimplementing per service
- Designing for multiple consumer types (web, mobile, third-party) that need different API shapes from the same backend
- Aggregating calls to multiple downstream services into a single consumer-facing response
- Migrating a monolith to services while maintaining a stable external API surface
- Applying traffic management (A/B routing, canary, circuit breaking) at the edge

## Core Principles

**The Gateway Is a Cross-Cutting Concern Platform, Not a Business Logic Layer.** Auth verification, rate limiting, request logging, TLS termination, response caching, and protocol translation are legitimate gateway concerns. Business logic is not. A gateway that validates business rules, enriches requests with domain data, or performs multi-step orchestration is a service masquerading as infrastructure. When this boundary is violated, the gateway becomes a deployment bottleneck and a test liability.

**BFF Pattern Serves Consumer-Specific API Shapes.** A single monolithic gateway serving web, mobile, and third-party consumers must make trade-offs that serve none of them optimally — web apps want aggregated data with navigation state; mobile clients want minimal payloads; third-party integrators want stable, versioned, general-purpose APIs. The Backend-for-Frontend (BFF) pattern addresses this by deploying a dedicated gateway per consumer type, owned by the team that owns the consumer. Each BFF shapes the API for its consumer without compromise.

**Route Configuration Is Infrastructure as Code.** Gateway routing rules (path matching, header-based routing, upstream targets) must be version-controlled and deployed through the same pipeline as service code. Ad-hoc gateway configuration changes are the primary source of production incidents in gateway-heavy architectures. Every routing rule must have: a source of truth in code, a review process, and automated validation before deployment.

**Rate Limiting Requires a Distributed Counter.** A gateway running multiple instances with per-instance in-memory rate counters will allow N times the intended rate, where N is instance count. Rate limiting in a distributed gateway requires a shared counter — Redis with atomic increment and TTL is the standard implementation. Design rate limit keys carefully: by IP (coarse, ineffective against distributed attack), by API key (correct for partner APIs), by user ID (correct for authenticated consumer APIs), or a combination.

**Auth Offloading Shifts Trust to the Gateway.** When the gateway validates JWTs and forwards a trusted identity header (`X-User-Id`) to downstream services, downstream services trust that header unconditionally. A bypass of the gateway (direct call to an internal service) with a forged header compromises the entire system. Internal services must be network-isolated such that they are unreachable except through the gateway or service-to-service paths. This is a deployment topology requirement, not a code requirement.

## Approach

Map consumer types first. Who calls the gateway? Web application, mobile app, third-party partners, internal services, IoT devices. Each consumer type likely has different auth mechanisms (session cookies, JWTs, API keys, mTLS certificates), different acceptable latencies, different payload size tolerances, and different versioning requirements. This mapping drives whether a single gateway or multiple BFFs are appropriate.

Define cross-cutting concern ownership. For each concern (auth, rate limiting, logging, caching, CORS, request validation, response transformation), decide: gateway responsibility or service responsibility? Auth and rate limiting almost always belong at the gateway. Business-rule validation (not schema validation) belongs in services. Schema validation (is this JSON well-formed, does it have required fields?) can live at the gateway as a defence-in-depth measure.

Design the routing table with path-based and header-based routing. Path prefixes route to upstream services: `/api/orders/*` → Order Service, `/api/inventory/*` → Inventory Service. Header-based routing supports API versioning (`Accept-Version: v2` → v2 upstream) and canary releases (`X-Canary: true` → canary deployment). Ensure the routing table is tested — an incorrectly routed request is a security issue if it reaches the wrong service.

For aggregation (fan-out and merge), decide whether the gateway or a dedicated aggregation service is the right home. A gateway plugin that calls three downstream services in parallel and merges responses is operationally complex and tightly couples the gateway to service API contracts. A dedicated aggregation BFF that calls services and merges is more maintainable and independently deployable. Reserve gateway aggregation for simple cases.

Plan for gateway availability as an architectural concern. A gateway that is a single point of failure for all traffic must have: horizontal scaling, health checks from a load balancer, graceful shutdown handling in-flight requests, and a circuit breaker for each upstream. A gateway that itself goes down takes the entire system's external surface with it.

## Common Mistakes to Avoid

- **Business logic in gateway plugins.** Pricing rules, eligibility checks, or data enrichment in gateway middleware create a deployment coupling between infrastructure and domain logic. Extract to a service.
- **Single gateway for all consumer types.** A gateway making field-level trade-offs between mobile minimal responses and web full-detail responses satisfies neither. BFF per consumer type where access patterns diverge significantly.
- **Per-instance rate limit counters.** Multi-instance gateway with in-memory counters allows burst rates that are N times the limit. Distribute the counter.
- **Gateway as a synchronous aggregation layer for complex workflows.** A gateway that calls 8 downstream services in a dependency chain with timeouts is a distributed transaction with no compensation mechanism. Move complex aggregation to a dedicated service.
- **Undocumented gateway routing rules.** Gateway configuration maintained in a vendor UI or YAML files not in version control is unauditable and unrecoverable. Every routing rule, rate limit, and auth policy must be in version control.

## Output

API gateway design output includes: consumer type map with auth mechanism per consumer; cross-cutting concern ownership matrix (gateway vs service); routing table with path, header, and upstream targets; BFF decomposition decision with rationale; rate limiting strategy with key selection and backend (Redis configuration); auth offloading mechanism and downstream trust model; availability design (scaling, circuit breakers, health checks); and configuration-as-code structure for all gateway rules.
