---
name: edge-computing
description: Edge computing patterns skill — apply CDN logic, edge functions, and data locality to reduce latency, offload origin, and handle data sovereignty; use when latency optimisation or geographic distribution is an architectural driver.
---

# Edge Computing

You design systems that execute logic and serve data from points of presence close to users — reducing round-trip latency, offloading origin infrastructure, and satisfying data locality requirements through deliberate placement of compute and cache.

## When to Use

- Reducing time-to-first-byte for globally distributed users where origin round-trip latency dominates
- Offloading authentication, rate limiting, or A/B testing logic from origin servers to the edge
- Satisfying data residency requirements that prohibit certain data from leaving specific geographic regions
- Implementing personalisation or geo-specific content delivery without origin round-trips
- Designing resilient architectures where edge nodes continue serving cached content during origin outages

## Core Principles

**Latency Is a Function of Distance and Network Hops.** The speed-of-light delay between a user in Sydney and an origin server in us-east-1 is roughly 170 ms round-trip before any application processing. A CDN PoP in Sydney reduces that round-trip to 5-10 ms for cached responses. Edge computing extends this — not just serving static assets from the edge, but executing logic (auth verification, routing decisions, personalisation lookups) at the PoP. The architectural question is not "should we use edge?" but "which computations are worth moving to the edge, and what constraints does that impose?"

**Edge Functions Are Constrained Compute, Not General-Purpose Servers.** Cloudflare Workers, Lambda@Edge, Vercel Edge Functions, and Fastly Compute all execute at the edge, but with constraints: execution time limits (1-50 ms CPU time per request), memory limits (128 MB-256 MB), no persistent local disk, limited compute APIs (no native modules, limited filesystem access), and cold start characteristics. Code that is appropriate for an origin server (connecting to a primary database, running ML inference, accessing a large in-memory cache) is inappropriate for an edge function. Edge functions are suited for: request routing, auth token verification (JWT validation without database lookup), response header manipulation, A/B test assignment, and simple data transformations against edge-cached data.

**Cache Invalidation at the Edge Requires Explicit Strategy.** CDN caches are distributed — invalidating a cache entry requires propagating the invalidation to all PoPs globally, which takes seconds to minutes. "Purge all" is the nuclear option; targeted purge by URL or cache tag is the right tool. Cache-tag-based invalidation (Fastly, Cloudflare) allows tagging cached responses with content identifiers and purging all responses with a given tag (e.g., purge all cached responses tagged `product:12345` when product 12345 is updated). Design the cache key and tag strategy before deployment; retrofitting it is expensive.

**Data at the Edge Must Be Treated as Ephemeral.** Edge workers do not have access to a centralised, persistent datastore with strong consistency guarantees. Edge KV stores (Cloudflare KV, Fastly Config Stores) are eventually consistent — a write at one PoP may take seconds to minutes to propagate to other PoPs. Edge databases (D1, Turso, Neon edge replicas) provide read replicas at the edge with sub-millisecond local reads, but writes still go to origin. Design edge data access as: reads from edge-local replicas or KV (fast, eventually consistent), writes to origin (slower, strongly consistent). Never design edge functions to be the system of record.

**Data Sovereignty Requires Jurisdiction-Aware Routing.** Data residency regulations (GDPR, data localisation laws in Brazil, India, Russia, China) may prohibit certain data from being processed outside a specific jurisdiction. Edge compute can enforce this: a routing layer at the edge classifies requests by user jurisdiction (IP geolocation, user account metadata) and routes to a regional origin that processes and stores data within the required jurisdiction. The edge layer enforces the routing policy; the origin layer enforces the storage isolation. Both must be auditable.

## Approach

Identify the latency-sensitive request types. Not all requests benefit equally from edge execution. Static assets (JS, CSS, images, fonts): high cache-hit rate, massive benefit from CDN. API responses for authenticated users with user-specific content: low cache-hit rate, limited direct benefit unless edge personalisation is applied. Unauthenticated, shareable content (product pages, public data): high cache-hit rate with cache-vary strategies. Prioritise edge caching and execution for high-volume, high-cache-hit request types.

Design the cache hierarchy explicitly. Browser cache → CDN edge PoP → origin. Define TTL per resource type: immutable assets (content-hashed filenames) cache for 1 year; HTML pages cache for 60 seconds with stale-while-revalidate; API responses for authenticated users cache at the browser only with no CDN caching; public API responses cache at the CDN for 30 seconds. The cache-control header on every response must be deliberate — a missing cache-control header means the CDN applies its default behaviour, which varies by provider.

Implement edge auth verification to avoid origin round-trips for authentication. A JWT signed with a key the edge function can verify allows the edge to validate the token locally (no origin call) and attach user identity claims to the forwarded request. Origin sees an already-verified identity claim rather than a raw token. This removes the auth verification cost from every origin request and reduces origin load proportionally to the percentage of authenticated traffic.

For personalisation at the edge, use edge KV to store user segment or variant assignment. On each request: look up user segment from edge KV (sub-millisecond), apply variant logic, serve segment-specific content. The KV store is populated asynchronously by an origin service as users are assigned to segments. The edge function never blocks on origin for personalisation decisions.

Design the fallback for edge function failure. Edge functions are highly available but not infallible. A misconfigured or crashing edge function must not return errors to users — it must fall back to origin pass-through. Implement an error boundary in every edge function: catch unhandled exceptions and fall through to origin fetch. Errors are logged to edge telemetry; the origin continues serving as if the edge function did not exist.

## Common Mistakes to Avoid

- **Executing database queries in edge functions.** An edge function that queries a centralised PostgreSQL instance on every request gets no latency benefit — the database round-trip is the bottleneck, and now it goes through the edge with added overhead. Edge functions must not block on origin datastores.
- **No cache-tag strategy before deployment.** Deploying to a CDN without cache tags means cache invalidation requires full-path purge, which either over-invalidates (cache miss storm) or leaves stale content serving. Design cache tags at deployment time.
- **Ignoring edge KV eventual consistency.** Treating edge KV as strongly consistent will produce correctness bugs when a write at one PoP is not yet visible at another. Every read from edge KV must tolerate stale data.
- **Data residency enforcement through client IP geolocation only.** IP geolocation is unreliable — VPNs, proxies, and CDN anycast IPs produce incorrect results. Combine IP geolocation with user account jurisdiction (set at registration and stored in the identity system) for reliable data residency enforcement.
- **Personalisation that varies the cache key unboundedly.** Varying the CDN cache by user ID produces a unique cached response per user — the cache-hit rate is zero and the CDN becomes a transparent proxy. Vary the cache only by user segment (a small finite set), not by individual user identity.

## Output

Edge computing design output includes: request type classification (static, shared dynamic, personalised, authenticated) with cache strategy per type; edge function scope (which logic executes at edge vs origin); cache hierarchy design with TTL per resource type and cache-tag strategy; edge KV data model with consistency tolerance per use case; edge auth verification design; data residency routing map with jurisdiction classification logic; fallback behaviour for edge function failures; and a performance baseline (measured round-trip latency improvement by region vs origin-only architecture).
