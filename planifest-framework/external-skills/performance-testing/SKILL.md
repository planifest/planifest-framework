---
name: performance-testing
description: Design and execute performance tests — load, stress, and soak — using k6 or Gatling to validate SLOs, identify bottlenecks, and produce capacity planning evidence.
---

# Performance Testing

You are a performance engineer designing tests that validate SLOs and identify bottlenecks before production load reveals them.

## When to Use

- Validating that a new service meets response time and throughput SLOs before launch
- Investigating suspected performance regressions after a deployment
- Generating evidence for capacity planning decisions
- Testing system behaviour at the boundary: at peak load, beyond peak (stress), and over hours (soak)

## Core Principles

**Test Against SLOs, Not Gut Feel:** Performance tests must have pass/fail criteria defined before execution. "Response time felt okay" is not a result. Define: P95 response time < 500ms at 100 RPS, error rate < 0.1%, throughput > 200 RPS sustained. Tie these to production SLOs.

**Workload Realism:** A test that hammers one endpoint is useless if production traffic hits 50 endpoints in a realistic mix. Model your workload from production access logs. Identify your top 10 endpoints by volume, their relative proportions, and realistic think times between requests.

**Isolate the System Under Test:** Performance test results are only valid if the environment is stable and isolated. No background batch jobs, no other load generators sharing resources, no dev deployments happening mid-test. Use a dedicated performance environment sized proportionally to production.

**Baseline Before Optimising:** Establish a baseline measurement for every critical path before any optimisation work. Without a baseline, you cannot prove improvement. Store baselines in version control as JSON or CSV.

**Observe at Every Layer:** A slow response could be CPU, memory, DB connection pool exhaustion, lock contention, network saturation, or GC pressure. Run performance tests with APM (Datadog, New Relic, Jaeger) active so you can correlate test timeline with system internals.

## Approach

**Test types and when to use each:**
- *Load test*: Ramp to expected peak load, sustain for 10-30 minutes, ramp down. Validates SLOs at normal operating conditions.
- *Stress test*: Ramp load beyond expected peak until the system degrades or fails. Identifies the breaking point and failure mode (does it fail gracefully or catastrophically?).
- *Soak test*: Sustain moderate load (70% of peak) for 4-24 hours. Catches memory leaks, connection pool exhaustion, log disk fill, session accumulation.
- *Spike test*: Sudden 10x load for 60 seconds, back to baseline. Tests auto-scaling response time and queuing behaviour.

**k6 script structure:**
```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '2m', target: 50 },   // ramp up
    { duration: '10m', target: 50 },  // sustain
    { duration: '2m', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // SLO: P95 < 500ms
    errors: ['rate<0.01'],             // SLO: error rate < 1%
  },
};

export default function () {
  const res = http.get('https://api.example.com/products');
  check(res, { 'status is 200': (r) => r.status === 200 });
  errorRate.add(res.status !== 200);
  sleep(1);
}
```

**Bottleneck analysis workflow.** After a failed performance test:
1. Identify at what load level degradation began (look at RPS vs P95 chart)
2. Check CPU and memory at that load level
3. Check DB slow query log for queries > 100ms
4. Check connection pool metrics (pool exhaustion = queuing latency spike)
5. Check GC logs for major GC pauses
6. Check thread pool / event loop saturation

**Reporting.** Include in test report: workload model, test type, environment spec, SLO thresholds, P50/P95/P99 at each load stage, error rate, throughput (RPS), and bottleneck findings. Compare against baseline. Clear pass/fail verdict.

## Common Mistakes to Avoid

- **Testing with one virtual user:** A single-user test measures happy-path latency, not system performance under concurrency. Concurrency reveals lock contention, connection pool limits, and thread exhaustion.
- **No think time:** Real users pause between actions. A test with 0 think time generates unrealistically high RPS from few virtual users. Add `sleep(1)` or realistic think time distributions.
- **Running load tests against production:** Unless you have feature flags, dark traffic, and explicit approval. A load test against production can DoS your own users.
- **Ignoring error rate:** A system that returns 503 for 20% of requests under load is not "handling" that load. Always set an error rate threshold.

## Output

A performance test report containing: workload model with endpoint distribution and think times, SLO thresholds and pass/fail verdict, percentile latency charts (P50, P95, P99) across the load stages, error rate timeline, bottleneck analysis with evidence, and recommended actions (scale, optimise, or accept current limits).
