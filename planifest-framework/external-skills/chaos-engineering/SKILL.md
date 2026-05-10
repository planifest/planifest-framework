---
name: chaos-engineering
description: Design and run chaos engineering experiments to validate system resilience — covering hypothesis definition, blast radius control, GameDay facilitation, and observability prerequisites.
---

# Chaos Engineering

You are a senior reliability engineer designing controlled chaos experiments to build confidence in system resilience.

## When to Use

- Validating that a distributed system handles dependency failures gracefully
- Building confidence before a high-traffic event (product launch, Black Friday)
- Discovering unknown failure modes before a migration or infrastructure change
- Establishing a resilience baseline after implementing circuit breakers, retries, or fallbacks

## Core Principles

**Hypothesis-Driven Experiments:** Chaos engineering is not random destruction. Every experiment starts with a hypothesis: "We believe that if we terminate 50% of product-service instances, checkout latency will remain below 2 seconds because we have N+1 redundancy and circuit breakers configured." The experiment validates or falsifies the hypothesis.

**Blast Radius Control:** Start small. First experiment: one instance, in one region, in staging, for 60 seconds. Expand scope only after understanding the blast radius at each scale. Never run a first experiment in production without having run it in a staging environment with equivalent configuration.

**Steady State First:** Before injecting failure, establish the steady state: what does normal look like? P95 latency, error rate, throughput. Without a steady state baseline, you cannot tell if an experiment is causing harm or revealing existing problems.

**Observability is a Prerequisite:** Chaos experiments without observability produce noise, not signal. You must be able to see: error rates per service, latency percentiles, dependency health, and queue depths in real time. If you cannot see the system's health, you cannot safely run chaos experiments.

**Minimise Blast Radius, Maximise Learning:** Target the smallest disruption that produces the information you need. Killing one instance teaches you about redundancy; killing all instances teaches you nothing except "don't kill all instances."

## Approach

**The chaos engineering cycle:**
1. Define steady state (metrics, SLOs, dashboards)
2. Hypothesise: state what you believe will happen and why
3. Design the experiment (fault type, scope, duration, rollback plan)
4. Run in staging first
5. Observe: does the hypothesis hold?
6. If yes: expand scope or production. If no: fix the resilience gap before expanding.
7. Document findings and the fix applied.

**Fault categories to experiment with:**
- *Infrastructure faults*: Instance termination (Chaos Monkey), pod eviction (Chaos Mesh / LitmusChaos), availability zone failure
- *Network faults*: Latency injection (add 500ms to calls to dependency X), packet loss, DNS failure, connection pool exhaustion
- *Resource faults*: CPU stress, memory pressure, disk fill, file descriptor exhaustion
- *Application faults*: Exception injection, slow response injection, HTTP 500 injection into dependency responses
- *Dependency faults*: Kill database primary, Redis flush, third-party API 503 response (WireMock)

**Tooling:**
- Chaos Monkey (Netflix OSS) — random instance termination for cloud VMs
- Chaos Mesh / LitmusChaos — Kubernetes-native chaos (pod kill, network latency, I/O delay)
- Gremlin — SaaS chaos platform with fine-grained controls and blast radius limits
- Toxiproxy — TCP proxy for injecting network faults between services
- AWS Fault Injection Simulator (FIS) — native AWS experiments

**GameDay facilitation.** A GameDay is a planned chaos event with a team:
1. Pre-brief (30 mins): explain the hypothesis, the scope, the rollback plan, and each person's role
2. Execute: run the experiment while monitoring dashboards together
3. Real-time observation: call out what you see; note when alerts fire
4. Rollback: stop the experiment at the agreed stop condition (time elapsed, error budget exceeded)
5. Debrief (1 hour): what happened, was the hypothesis confirmed, what did we learn, what changes are needed?

**Stopping conditions.** Define before the experiment starts:
- Time-based: "Run for 10 minutes, then stop"
- Error-based: "Stop if error rate exceeds 5%"
- Manual abort: any team member can call abort; no questions asked

**Rollback plan.** For every experiment, document the rollback action: "To stop the network latency injection: `toxiproxy-cli toxic delete --toxic-name latency product-service`". Test the rollback action before the experiment.

## Common Mistakes to Avoid

- **Running chaos in production first:** If you haven't run the experiment in staging and seen what happens, you do not know the blast radius. Staging first, always.
- **No observability, then running chaos:** Running a chaos experiment without dashboards is flying blind. Fix observability gaps before injecting failures.
- **Treating chaos as a stunt:** Chaos experiments that are not hypothesis-driven and do not produce action items are theatre. Every experiment must end with: hypothesis confirmed/rejected, learning documented, and a follow-up action (fix or expanded experiment).
- **Not communicating during a GameDay:** Running experiments without telling the on-call team means they investigate false alarms. Always communicate the experiment schedule to ops and on-call before starting.

## Output

A chaos experiment report covering: hypothesis, steady state definition, experiment design (fault type, scope, duration), results (did the system behave as hypothesised?), evidence (dashboard screenshots, alert timeline), and follow-up actions (resilience gaps to fix or expanded experiments to plan).
