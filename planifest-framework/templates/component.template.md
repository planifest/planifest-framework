---
# Planifest Component Manifest
# See p007 for the full Domain Knowledge Service schema.
id: "{{component-id}}"
name: "{{Human-Readable Name}}"
initiative: "{{initiative-id}}"
version: "0.1.0"
status: "planned | active | deprecated"
type: "microservice | microfrontend | component-pack"
domain: "{{domain-name}}"
stack:
  language: "typescript | go | python | rust"
  runtime: "node | deno | bun | go | python"
  framework: "fastify | express | hono | gin | flask"
  frontend: "react19 | vue | svelte | none"
  styling: "tailwind | css-modules | vanilla-css | none"
  componentLibrary: "shadcn-ui | radix | headless-ui | none"
  database: "postgresql | mysql | sqlite | mongodb | none"
  orm: "drizzle | prisma | typeorm | sqlc | none"
  testing: "vitest | jest | go-test | pytest"
  iac: "pulumi | terraform | cdk | none"
  cloud: "gcp | aws | azure | none"
  compute: "cloud-run | lambda | ecs | k8s | none"
  ci: "github-actions | gitlab-ci | bitbucket-pipelines"
contract:
  apiSpec: "plan/{{initiative-id}}/openapi-spec.yaml"
  inputs:
    - name: "{{endpoint-or-event-name}}"
      type: "http | grpc | event | queue"
      description: "What this input accepts"
  outputs:
    - name: "{{endpoint-or-event-name}}"
      type: "http | grpc | event | queue"
      description: "What this output produces"
  consumedBy: []
  consumes: []
  breakingChangePolicy: "requires-adr | requires-human-approval | semver-major"
data:
  ownsData: true
  dataContract: "src/{{component-id}}/docs/data-contract.md"
  tables: []
  schemaVersion: "0.0.0"
  migrationPath: "src/{{component-id}}/docs/migrations/"
quality:
  testCoverage:
    unit: 0
    integration: 0
    e2e: 0
pipeline:
  templateVersion: "1.0.0"
  initiativeMode: "greenfield | retrofit | agent-interface"
  domainKnowledgePath: "plan/{{initiative-id}}/docs"
metadata:
  createdAt: "{{ISO-8601}}"
  updatedAt: "{{ISO-8601}}"
  createdBy: "agent | human"
  lastModifiedBy: "agent | human"
  skill: "{{skill-name}}"
  tool: "{{agentic-tool-name}}"
  model: "{{model-name-and-version}}"
---

# {{Human-Readable Name}}

**Summary:** One sentence: what this component exists to do.

**System Context:** Where this component sits in the wider system and why it exists.

## Responsibilities
- First thing this component is responsible for
- Second thing this component is responsible for

## Not Responsible For
- Explicit exclusion - what this component must NOT do
- Another exclusion - equally important as responsibilities

## Scope
### In Scope
- What is explicitly in scope for this component

### Out of Scope
- What is explicitly out of scope

### Deferred
- What is deferred to a future initiative

## Risk
**Level:** low | medium | high | critical

### Risk Items
- Item 1
- Item 2

## Tech Debt & Quirks
- Debt item 1
- Quirk 1
