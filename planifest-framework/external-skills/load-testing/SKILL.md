---
name: load-testing
description: Design realistic load tests with accurate workload models, ramp-up patterns, and percentile analysis to produce capacity planning evidence and validate SLOs under production-representative load.
---

# Load Testing

You are a performance engineer designing load tests that produce actionable capacity planning evidence, not just latency numbers.

## When to Use

- Establishing how many users or requests per second a system can handle at SLO targets
- Generating capacity planning evidence before scaling decisions (instance sizing, auto-scale thresholds)
- Validating that a new deployment maintains throughput parity with the previous version
- Producing data for setting auto-scaling trigger points

## Core Principles

**Workload Realism:** A load test that sends 1,000 requests per second to `/health` is not a load test — it's a benchmark of your health endpoint. Realistic load tests model production traffic: the mix of endpoints, the distribution of request sizes, the user think times between actions, and the authentication overhead.

**Percentile Analysis Over Averages:** Average response time hides pathological behaviour. P50 of 100ms with P99 of 5,000ms means 1% of users experience 5-second responses. SLOs should specify percentiles: "P95 < 500ms, P99 < 2s". Report P50, P95, P99, and P99.9 for every endpoint.

**Throughput Ceiling vs Latency Target:** Two different questions. "What is the maximum throughput the system can sustain?" (stress test) vs "Does the system meet latency SLOs at expected throughput?" (load test). Define which question you're answering before designing the test.

**Environment Proportionality:** A load test environment that is 25% of production size must be interpreted accordingly — multiply throughput results by 4 to project production capacity. Document the environment size ratio in every report. Better: test at full production scale for capacity planning.

**Concurrency vs Throughput:** Distinguish between concurrent virtual users (VUs) and requests per second (RPS). 100 VUs with 1s think time generates approximately 100 RPS. 100 VUs with 0s think time generates as many RPS as the system can respond to. Choose VUs and think time to model the target RPS realistically.

## Approach

**Workload modelling from production logs.**
```bash
# Extract top endpoints from access log
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -20
```
Calculate the relative proportion of each endpoint. If `/products/list` is 30% of traffic, it should be 30% of your load test VU budget.

Model user journeys, not just endpoints:
- Anonymous browse: product list → product detail → search (30% of traffic)
- Add to cart: login → browse → add to cart → view cart (40% of traffic)
- Purchase: login → checkout → payment → order confirmation (30% of traffic)

Build k6 scenarios matching these proportions using `scenarios` config with `weight`.

**k6 workload model with scenarios:**
```javascript
export const options = {
  scenarios: {
    browse: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 30 },   // ramp: 30% of 100 target
        { duration: '20m', target: 30 },  // sustain
        { duration: '5m', target: 0 },
      ],
    },
    purchase: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 30 },
        { duration: '20m', target: 30 },
        { duration: '5m', target: 0 },
      ],
    },
  },
  thresholds: {
    'http_req_duration{scenario:purchase}': ['p(95)<800'],
    'http_req_duration{scenario:browse}': ['p(95)<300'],
    http_req_failed: ['rate<0.005'],
  },
};
```

**Ramp-up patterns.** Never start at full load — servers need warmup time (JVM JIT, connection pool fill, cache population). Standard ramp: 0 → 10% over 2 minutes, 10% → 100% over 5 minutes, sustain 100% for 15 minutes, ramp down over 2 minutes. For spike tests: 0 → 100% in 10 seconds.

**Percentile analysis.** Collect at minimum: P50, P95, P99 per endpoint. Chart them over time — a P99 that climbs during the sustain phase indicates memory pressure, cache thrashing, or connection pool degradation. A flat P50 with a rising P99 indicates occasional slow queries or GC pauses.

**Capacity planning output.** The deliverable is not "P95 is 450ms." It is:
- Current capacity: the system sustains X RPS with SLOs met
- Head room: SLOs breach at Y RPS (Y/X = safety margin)
- Scaling trigger: at Z RPS, add N instances to restore head room
- Cost model: each additional instance adds $M/month; Z RPS is expected at [date/event]

**Think time and pacing.** Production users pause between actions. Model think time with realistic distributions, not fixed sleeps. In k6: `sleep(Math.random() * 2 + 0.5)` simulates 0.5-2.5 second pauses. Think time dramatically affects the VU count needed to hit a target RPS.

## Common Mistakes to Avoid

- **No ramp-up:** Starting 1,000 VUs simultaneously creates an unrealistic spike that overwhelms connection pools. Real traffic ramps up. Ramp your load test.
- **Testing a single endpoint:** A test that only hits `/api/products` does not reveal database contention caused by concurrent reads and writes across endpoints. Model the full traffic mix.
- **Reporting only averages:** Average response time is the most misleading metric. P95 and P99 are what users at the tail experience. Report percentiles.
- **Accepting "it passed" without examining the shape:** A test can technically pass thresholds while showing degradation curves. Always plot latency over time — a rising trend during the sustain phase means the system is not truly stable at that load.

## Output

A load test report containing: workload model with endpoint distribution and source data, environment specification with production ratio, SLO thresholds and pass/fail verdict, P50/P95/P99 over time charts for each endpoint group, capacity ceiling with safety margin, auto-scaling trigger recommendations, and cost model for next capacity tier.
