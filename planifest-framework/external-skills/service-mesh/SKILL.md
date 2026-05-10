---
name: service-mesh
description: Service mesh skill — apply the sidecar pattern for mTLS, traffic management, and observability across microservices; evaluate Istio vs Linkerd trade-offs; use when per-service network policy and distributed observability cannot be achieved through code-level libraries.
---

# Service Mesh

You apply infrastructure-level networking capabilities — mutual TLS, retries, circuit breaking, traffic shaping, and distributed tracing — across all services uniformly, without requiring each service to implement these concerns in its own code.

## When to Use

- Enforcing zero-trust network security (mTLS) across all service-to-service communication without modifying service code
- Applying consistent retry, timeout, and circuit breaker policies across dozens of services without per-service library configuration
- Enabling advanced traffic management (weighted routing, mirroring, canary releases) at the infrastructure layer
- Gaining deep observability (latency histograms, error rates, dependency maps) across all service pairs without instrumenting each service individually
- Evaluating whether a service mesh's operational overhead is justified for a given system's complexity

## Core Principles

**Sidecar Proxy Is the Mechanical Foundation.** A service mesh deploys a proxy sidecar (Envoy in Istio; a custom Rust/Go proxy in Linkerd) alongside every service instance. All inbound and outbound network traffic passes through the sidecar. The sidecar enforces policy (mTLS, retries, timeouts), collects telemetry (request rates, latency, error rates), and reports to the control plane. The service itself is unaware of the mesh — it communicates with its sidecar on localhost, which communicates with the remote sidecar.

**mTLS Eliminates Lateral Movement, Not Perimeter Attacks.** Mutual TLS in a service mesh means every service-to-service connection is authenticated by certificate and encrypted. A compromised pod cannot make an authenticated call to a service it is not permitted to reach — the sidecar rejects it. This eliminates lateral movement after a breach. It does not eliminate perimeter attacks (traffic from outside the mesh) — combine with network policies and ingress controls. Certificate rotation must be automatic; manually managed mTLS certificates degrade to no mTLS in practice.

**Traffic Management Enables Zero-Downtime Operations.** A service mesh enables traffic management without code changes: weighted routing (send 10% of traffic to v2), traffic mirroring (copy production traffic to a shadow service for testing), fault injection (return 5xx to 1% of requests to test resilience), and header-based routing (route users with `X-Beta: true` to the canary). These capabilities make progressive delivery — canary releases, blue-green deployments, A/B testing — operationally tractable at scale.

**Observability Is a Mesh Byproduct, Not an Add-on.** Because every request passes through a sidecar, the mesh can emit a uniform telemetry signal — request rate, error rate, latency (RED metrics) — for every service pair, without service instrumentation. Service dependency maps are built automatically from observed traffic. This is the primary observability argument for a mesh: you do not need to instrument 50 services individually to know which service is the latency bottleneck in a distributed trace.

**Operational Complexity Is Real and Must Be Justified.** Istio adds the control plane (istiod), the sidecar lifecycle management, the CRD configuration surface (VirtualServices, DestinationRules, PeerAuthentications, AuthorizationPolicies), and the certificate authority. This is significant operational overhead — misconfigured Istio policies are a common source of production outages. Linkerd has a simpler operational model but fewer features. The mesh is justified when: you have 10+ services, you cannot enforce mTLS at the code level, and you need uniform observability and traffic management. Below this threshold, the overhead exceeds the benefit.

## Approach

Before choosing a mesh, enumerate the capabilities you actually need. If you need only mTLS, a PKI with mutual TLS configured in each service's library might be simpler. If you need traffic management and observability at scale, a mesh is justified. Avoid adopting a mesh because it is modern — adopt it because specific capabilities cannot be achieved otherwise at acceptable cost.

Choose between Istio and Linkerd based on operational profile. Istio: richer feature set (circuit breaking, fault injection, traffic mirroring, WASM extensions, JWT validation at sidecar), wider adoption, heavier control plane, steeper learning curve, larger attack surface. Linkerd: simpler, lighter, faster sidecar (Rust), narrower feature set, excellent mTLS and observability, less configurable traffic management. For teams without Kubernetes infrastructure expertise, Linkerd's simpler operational model reduces the risk of misconfiguration-induced outages.

Deploy incrementally. Add the mesh in permissive mode (mTLS available but not enforced) first. Observe traffic in the mesh control plane — identify all service-to-service communication paths. After verifying all paths are captured, switch to strict mode (mTLS enforced, plaintext rejected). This prevents the silent failures that occur when strict mode is applied before all services are mesh-enrolled.

Define AuthorizationPolicies (Istio) or Server policies (Linkerd) explicitly for each service. The default-deny model — deny all inter-service traffic, permit only what is explicitly authorised — is the correct baseline. A policy of permit-all defeats the purpose of mTLS identity. Document each allowed communication path in the policy configuration.

Instrument the mesh metrics pipeline. Sidecar metrics are emitted in Prometheus format; scrape them with Prometheus or a compatible agent. Visualise service topology in Kiali (Istio) or Linkerd's built-in dashboard. Wire distributed trace context (B3 or W3C TraceContext headers) through the mesh — the sidecar propagates trace headers automatically for HTTP/2 and gRPC; HTTP/1.1 may require application-level header propagation.

## Common Mistakes to Avoid

- **Applying strict mTLS before all services are enrolled.** Services not yet injected with a sidecar will fail to connect when strict mTLS is enforced. Always validate in permissive mode first.
- **Default-allow AuthorizationPolicies.** mTLS authenticates identities; authorisation policies control which identities may talk to which services. mTLS without authorisation policies is encryption without access control.
- **Misconfiguring DestinationRules before VirtualServices.** Istio applies DestinationRules before routing is evaluated; a DestinationRule that references a subset not yet defined in a VirtualService causes 503 errors in production. Apply configuration changes in dependency order.
- **Ignoring control plane resource limits.** Istiod running without memory limits on a large cluster will be OOMKilled during a surge in configuration updates, leaving the data plane running on stale configuration. Set and test control plane resource limits.
- **Adopting a mesh for teams lacking Kubernetes operational expertise.** A service mesh misconfiguration can silently drop all traffic between services or silently disable mTLS. The team must have the expertise to diagnose mesh-layer failures before adopting.

## Output

Service mesh design output includes: capability justification matrix (what the mesh provides vs alternatives); mesh product selection with rationale; enrollment plan (incremental permissive-to-strict rollout); AuthorizationPolicy catalogue (per-service allowed callers); traffic management policy per service (retries, timeouts, circuit breaker thresholds); observability pipeline design (metrics scrape, trace propagation, dashboard); and an operational runbook for common mesh failures (sidecar injection failure, certificate rotation failure, policy misconfiguration).
