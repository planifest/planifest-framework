---
name: serverless-architecture
description: Serverless architecture skill — design function granularity, address cold starts, manage distributed state, model costs, and reason about vendor lock-in; use when designing event-driven systems where per-invocation billing and operational simplicity are architectural drivers.
---

# Serverless Architecture

You design serverless systems that are cost-efficient, operationally simple, and avoid the common failure modes — cold start latency, state mismanagement, cost explosion, and irrecoverable vendor coupling.

## When to Use

- Building event-driven workloads with highly variable or spiky invocation rates where always-on compute is wasteful
- Designing integration pipelines, webhooks, scheduled jobs, or data transformation workflows
- Optimising operational overhead for teams without platform engineering capacity
- Evaluating whether serverless unit economics apply to a specific workload's access pattern
- Building the edge layer of a system where functions execute close to users (edge functions)

## Core Principles

**Function Granularity Is a Trade-off Between Coupling and Overhead.** A single function per HTTP route produces maximal operational isolation, independent deployability, and precise cost attribution, but multiplies cold start surface, deployment complexity, and IAM configuration. A single monolithic function handles all routes in one deployment, minimising overhead but forfeiting independent scalability and deployment. The right granularity is typically at the domain capability boundary — one function per capability (checkout, notifications, profile), not one per route. Avoid nano-functions (one function per database operation); avoid mono-functions (one function for the entire application).

**Cold Starts Are a Latency Budget, Not a Bug.** A cold start occurs when the runtime must initialise the function execution environment before processing the first request. Factors: runtime (JVM cold starts are 1-5 seconds; Node.js and Python are 100-500 ms; compiled Go/Rust are under 100 ms); package size (fewer dependencies = faster initialisation); VPC attachment (adds 1-3 seconds for ENI provisioning in AWS Lambda). Mitigations: provisioned concurrency (warm instances always available, at cost); language/runtime selection optimised for cold start; minimising dependency count. Design the cold start budget into the SLA — p50 latency may be 50 ms; p99.9 may be 3 seconds for low-traffic functions.

**State Must Live Outside the Function.** Function instances are ephemeral and may not persist between invocations. In-memory state (in-process caches, connection pools) does not survive across invocations — or across concurrent invocations of the same function. External state stores are mandatory: DynamoDB or Redis for session state, S3 for blob state, SQS or Kafka for work queues. The one legitimate in-process optimisation is connection pooling to external datastores within a warm instance's lifetime — but design the function to work correctly when that state is absent.

**Cost Modelling Is an Architectural Concern.** Serverless billing is per-invocation × duration × memory. A function that executes 1 million times per day at 500 ms and 512 MB costs a calculable amount — model it before committing to the architecture. Failure modes: a loop that invokes the function recursively; a function triggered by every row in a DynamoDB stream on a high-write table; a misconfigured SQS visibility timeout that causes all messages to be retried indefinitely. Cost anomalies in serverless are architecture bugs, not billing surprises.

**Vendor Lock-in Is a Risk to Manage, Not to Eliminate.** Using Lambda event sources (SQS, DynamoDB Streams, EventBridge) couples the system to AWS. Using proprietary extensions (Lambda Layers with vendor SDKs, Fargate task definitions) deepens coupling. Mitigations: isolate vendor-specific integration code in adapter layers behind interfaces (hexagonal architecture applied at the function boundary); use portable runtimes (container images instead of ZIP deployments); deploy via infrastructure-as-code that is provider-agnostic at the module level (AWS CDK or Terraform). Eliminating vendor coupling entirely typically costs more in complexity than it saves — manage it deliberately, do not pretend it does not exist.

## Approach

Map the workload's invocation pattern. Serverless unit economics are favourable when: average invocations per second is low (< 100 sustained), traffic is spiky (10x variance), and execution duration is short (< 30 seconds). Serverless unit economics become unfavourable when: sustained high concurrency (> 1,000 req/s), long execution duration (approaching the 15-minute Lambda limit), or tight latency SLAs that cannot tolerate cold starts. Always model the break-even point against reserved EC2 or Fargate capacity.

Design the function boundary by trigger type. One function per trigger type is a good starting heuristic: HTTP trigger functions, SQS consumer functions, scheduled functions, stream processor functions, and event-bus consumer functions have different deployment, scaling, and error-handling characteristics. An HTTP function and an SQS consumer that share the same code but different triggers should be separate deployments — their scaling and timeout configurations differ.

Handle idempotency at the function level. SQS, EventBridge, and DynamoDB Streams all deliver at-least-once. A function triggered by a message must be idempotent. Use idempotency keys stored in DynamoDB (with the message ID as the key and a short TTL) to detect and short-circuit duplicate executions. Without this, a retried message that partially executed the first time may corrupt state on the second execution.

Define the error handling strategy before deployment. An unhandled exception in an SQS consumer causes the message to return to the queue and be retried. Without a maximum receive count and a Dead Letter Queue configured, the message retries indefinitely, blocking all subsequent messages in a FIFO queue and incurring cost in a standard queue. Configure DLQs on all SQS-triggered functions; configure Lambda destinations for async invocations; alert on DLQ message counts.

Manage the dependency surface area aggressively. Lambda cold start time scales with package size. Use tree-shaking (esbuild, webpack) for Node.js to exclude unused code. Use Lambda Layers only for dependencies shared across many functions. For JVM-based functions, evaluate GraalVM native compilation or Quarkus/Micronaut frameworks designed for fast startup. Measure cold start time in CI as a regression test.

## Common Mistakes to Avoid

- **Stateful in-memory caching across invocations.** A function that caches database results in a module-level variable may serve stale data from a warm instance or fail entirely on a cold instance. External cache or accept that each cold invocation pays the data fetch cost.
- **Unbounded retry loops.** An SQS queue without a DLQ and maximum receive count retries failed messages indefinitely. This causes cost explosion and blocks FIFO queues. Always configure DLQs.
- **VPC-attached functions without justification.** Attaching a Lambda to a VPC adds cold start latency (ENI provisioning) and requires NAT gateway for internet access. Only attach to a VPC when the function must access VPC-private resources (RDS, ElastiCache in a private subnet).
- **Per-route nano-functions.** One Lambda per HTTP route across a 50-route API creates 50 deployment units, 50 IAM policies, 50 cold start surfaces, and massive operational overhead. Group related routes into a capability-level function.
- **No cost model before deployment.** A function triggered by a high-volume DynamoDB stream or SNS topic can generate millions of invocations per hour. Model the cost before enabling the trigger in production.

## Output

Serverless architecture output includes: workload invocation pattern analysis with break-even cost model; function boundary map by trigger type; cold start budget per function with mitigation strategy; state management design (external stores per state type); idempotency implementation per trigger type; DLQ and error handling configuration per function; vendor coupling assessment with isolation strategy; and a deployment topology showing function, trigger, DLQ, and downstream dependencies per capability.
