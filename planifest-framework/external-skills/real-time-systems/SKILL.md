---
name: real-time-systems
description: Real-time architecture skill — choose between WebSockets, SSE, long polling, and pub/sub for push delivery; design fan-out, presence systems, and connection management at scale; use when designing systems that deliver low-latency updates to connected clients.
---

# Real-Time Systems

You design architectures that deliver low-latency updates to connected clients — choosing the right push transport, designing scalable fan-out, and managing connection state across server instances.

## When to Use

- Designing live collaboration features (document editing, whiteboard, multiplayer)
- Building notification systems, activity feeds, or chat where users expect sub-second delivery
- Implementing presence systems (online/offline indicators, typing indicators, cursor positions)
- Designing trading dashboards, live sports scores, or monitoring systems with sub-second data freshness requirements
- Scaling a push delivery system beyond a single server instance

## Core Principles

**Transport Choice Follows Directionality and Latency Requirements.** WebSockets: bidirectional, persistent connection, minimal overhead per message after handshake; suited for interactive applications (chat, collaboration, gaming). Server-Sent Events (SSE): server-to-client unidirectional, built on HTTP, automatic reconnect with Last-Event-ID, simpler to implement and proxy-friendly; suited for push-only feeds (live dashboards, notification streams). Long polling: HTTP request held until data is available or timeout; maximum compatibility, higher per-message overhead; suited when WebSockets are blocked by corporate proxies. gRPC streaming: bidirectional streaming over HTTP/2, strongly typed, suited for service-to-service real-time communication.

**Stickiness or Shared State — Choose One.** A single WebSocket connection is pinned to a specific server instance. When the application scales horizontally, a message that must be delivered to a client on instance A but arrives at instance B requires a cross-instance delivery mechanism. Two approaches: sticky sessions (load balancer pins each connection to one instance — simple but limits horizontal scaling and complicates rolling deployments) or shared pub/sub backbone (each instance subscribes to a Redis Pub/Sub channel or Kafka topic per connection; messages are broadcast to all instances and delivered to the locally-connected client). The shared pub/sub approach scales horizontally without stickiness but adds latency from the pub/sub hop.

**Fan-out at Scale Requires Explicit Architecture.** Broadcasting a message to 100,000 connected clients (a sports score update) is a fan-out problem. Naive fan-out: the server iterates over all 100,000 connections and writes each message — this saturates the server's network I/O. Structured fan-out: publish the message to a pub/sub topic; multiple fan-out worker instances consume from the topic and each delivers to their locally-connected clients. For extreme scale (millions of connections), dedicated real-time infrastructure (Ably, Pusher, AWS API Gateway WebSocket) offloads fan-out to a managed platform.

**Presence Is Harder Than It Looks.** A presence system tracks which users are online. Naive approach: a heartbeat message from each client updates an in-memory map on the server. Problems: what happens when the server crashes? The presence state is lost. What happens on horizontal scale? Each server only knows about its own connections. Correct approach: heartbeats write to a shared TTL store (Redis EXPIRE); presence is the set of keys that have not expired. Expiry-based presence has a lag equal to the TTL window — design the TTL for the acceptable staleness of presence data.

**Message Ordering and Exactly-Once Delivery Are Application Concerns.** WebSockets and SSE provide ordered delivery within a connection but do not provide durable message delivery. If the client disconnects and reconnects, messages sent during the disconnection are lost. Applications that require durability must: assign sequence numbers or event IDs to messages; allow clients to reconnect with a "last received ID" to resume the stream; buffer recent messages server-side for reconnecting clients. SSE's `Last-Event-ID` header provides this mechanism natively; WebSocket applications must implement it in the application protocol.

## Approach

Define the data flow topology. Who produces updates? How do they reach the real-time layer? Typical architecture: domain services publish events to a message broker (Kafka, Redis Streams); a real-time delivery service (fan-out service) subscribes to the broker and delivers to connected clients. The real-time delivery service's only responsibility is connection management and delivery — no business logic.

Choose the connection management strategy. For fewer than 10,000 concurrent connections per instance, in-process connection management with a shared Redis pub/sub backbone is operationally simple. For more than 50,000 concurrent connections, evaluate connection management as a dedicated infrastructure layer (nginx with push module, a purpose-built WebSocket server like uWebSockets or Centrifugo). Node.js handles WebSocket connections efficiently due to its event loop; Java NIO and Go goroutines are also well-suited. Thread-per-connection models (thread-per-WebSocket in a traditional Java server) hit operating system limits around 10,000 connections.

Design the subscription model. Clients subscribe to channels or topics relevant to them (a chat room, a game session, a user's notification stream). The fan-out service maps each incoming event to the set of channels it affects and delivers to all subscribers of those channels. A flat global channel that all clients subscribe to does not scale — at 100,000 clients, every message is delivered to every client regardless of relevance.

Handle disconnection and reconnection explicitly. Design the reconnection protocol: on reconnect, the client sends its last received message ID. The server replays messages since that ID from a short-term buffer (Redis Sorted Set with score = sequence number, TTL = 60 seconds). This provides at-least-once delivery for the reconnection window. Messages older than the buffer TTL are acknowledged as missed; the client performs a REST API catch-up query to restore state.

Implement connection-level backpressure. A slow client that cannot consume messages fast enough will cause the server's write buffer to grow unboundedly. Implement a per-connection send buffer limit: if the buffer exceeds the threshold, disconnect the client rather than continuing to accumulate messages. The client will reconnect and resume. This prevents a single slow client from exhausting server memory.

## Common Mistakes to Avoid

- **WebSocket everything.** SSE is simpler, HTTP-compatible, and automatically reconnects. For push-only feeds (notifications, dashboards), SSE has lower implementation complexity and better proxy support than WebSockets. Reserve WebSockets for bidirectional interactive applications.
- **In-memory presence without TTL expiry.** A presence map that relies on explicit disconnect events will show dead users as online when their process crashes or their network cable is pulled. Always use TTL-based presence with heartbeat renewal.
- **No sequence numbers on messages.** A client that reconnects with no way to request missed messages will silently miss updates during the disconnection window. Assign sequence numbers; implement catch-up.
- **Fan-out without horizontal scaling plan.** A single server iterating 100,000 WebSocket connections for every score update is a CPU and network bottleneck that arrives without warning at scale. Design fan-out architecture before reaching the limit.
- **Ignoring load balancer WebSocket support.** ALBs and nginx handle WebSocket upgrades differently. A load balancer that does not support WebSocket connection persistence will break existing connections on backend restarts. Validate WebSocket behaviour through the full proxy stack in staging.

## Output

Real-time system output includes: transport selection per feature (WebSocket/SSE/long polling) with rationale; connection management architecture (per-instance in-memory vs shared state); fan-out design with scale estimate; pub/sub backbone selection and topology; presence system design with TTL strategy and staleness tolerance; subscription model (channels/topics per domain entity type); reconnection protocol with buffer design; backpressure mechanism; and a load test plan validating connection count and fan-out throughput targets.
