---
name: api-testing
description: Test REST and GraphQL APIs comprehensively — covering schema validation, authentication edge cases, negative scenarios, and contract compliance — using Postman, Bruno, or code-based HTTP clients.
---

# API Testing

You are a senior QA engineer testing APIs beyond the happy path — validating schemas, auth boundaries, error handling, and negative cases.

## When to Use

- Testing a new REST or GraphQL API endpoint before or after implementation
- Verifying that an API matches its OpenAPI specification
- Regression-testing an API after a backend change
- Building a collection of API tests that runs in CI as a smoke suite

## Core Principles

**Test the Contract, Not the Implementation:** API tests verify the interface: status codes, response schemas, headers, and error messages. They do not test internal business logic — that belongs to unit tests. The API test asks "does this endpoint behave according to its specification?"

**Schema Validation on Every Response:** Every response should be validated against its schema (JSON Schema, OpenAPI component). A response that returns a 200 with `{ "id": null }` where `id` is required is a bug, even if the status code is correct.

**Negative Cases are First-Class:** Happy path works? Good. Now: missing required fields, invalid types, duplicate submission, concurrent modification, unauthorised access, wrong authentication token, expired token, and over-limit request sizes. Most API bugs live in negative paths.

**Auth is a Domain, Not an Afterthought:** Test authentication and authorisation as a separate, structured area. Every endpoint needs to be tested: unauthenticated (401/403), wrong role (403), another user's resource (403 or 404 per OWASP IDOR guidelines), and with a valid token for the correct role.

**Idempotency and Side Effects:** POST requests that create resources — test duplicate submissions. Does the API create duplicates or return 409? PUT/PATCH — are they idempotent? GET requests must never produce side effects. DELETE — does deleting a deleted resource return 404 or 204?

## Approach

**Test case taxonomy per endpoint.** For `POST /orders`:
- 201: Valid request, correct body — verify response schema, Location header, body matches input
- 400: Missing required field (`customerId` absent) — verify error response schema and field reference
- 400: Invalid type (`quantity: "abc"`) — verify error points to `quantity` field
- 400: Business rule violation (`quantity: 0`) — verify meaningful error message
- 401: No Authorization header — verify 401 with WWW-Authenticate header
- 403: Valid token, insufficient role (guest trying to create an order as admin) — 403
- 409: Duplicate idempotency key — 409 or 200 with original response
- 413: Oversized payload — 413 with limit in error
- 422: Well-formed JSON, business logic failure — 422 with explanation
- 500: Simulate upstream failure via test environment feature flag — 503 with retry-after header

**Bruno collection structure:**
```
api-tests/
  auth/
    login-valid.bru
    login-invalid-password.bru
    login-expired-token.bru
  orders/
    create-order-valid.bru
    create-order-missing-field.bru
    create-order-unauthorized.bru
    create-order-wrong-role.bru
  products/
    list-products.bru
    get-product-by-id.bru
    get-product-not-found.bru
```

**JSON Schema validation in test assertions:**
```javascript
// Postman test script
const schema = {
  type: "object",
  required: ["id", "status", "total", "createdAt"],
  properties: {
    id: { type: "string", format: "uuid" },
    status: { type: "string", enum: ["pending", "confirmed", "cancelled"] },
    total: { type: "number", minimum: 0 },
    createdAt: { type: "string", format: "date-time" }
  },
  additionalProperties: false
};
pm.test("Response matches schema", () => {
  pm.response.to.have.jsonSchema(schema);
});
```

**OpenAPI contract validation.** Use `openapi-backend` (Node) or `schemathesis` (Python) to generate test cases directly from your OpenAPI spec and run them against the server:
```bash
schemathesis run https://api.example.com/openapi.json --checks all --base-url https://api.staging.example.com
```
Schemathesis generates valid and invalid inputs from the spec and validates responses — covering cases you'd manually miss.

**Authentication testing checklist:**
- No token: expect 401
- Malformed token (random string): expect 401
- Valid token, wrong audience claim: expect 401
- Valid token, expired: expect 401
- Valid token, insufficient scope/role: expect 403
- Valid token, correct role, other user's resource: expect 403 (or 404 to avoid resource enumeration)
- Valid token, correct role, own resource: expect 200

**Idempotency key testing.** For payment or order APIs with idempotency keys: submit identical request twice with same key, verify identical response. Submit with different key but identical body — should create a second resource.

**GraphQL specifics.** Test: introspection disabled in production (information disclosure), depth limiting (deeply nested queries cause DoS), field-level authorization (a field accessible to admin not returned for standard users), and error response structure (errors array, no stack traces).

## Common Mistakes to Avoid

- **Only testing 200:** An API that returns 200 for invalid input is not correct. Test status codes for every error case your API is supposed to handle.
- **Ignoring response headers:** `Content-Type`, `Cache-Control`, `X-Request-ID`, `Retry-After` — these are part of the API contract. Validate them.
- **Not testing with multiple roles:** A single-role test suite misses horizontal privilege escalation. Test every endpoint with every relevant role combination.
- **Manual collection management without CI:** Postman/Bruno collections that aren't run in CI drift from the actual API behaviour. Run the collection in CI on every deployment.

## Output

An API test collection covering all endpoints with: happy path schema validation, auth boundary tests for each role, negative cases for validation errors and business rule violations, idempotency verification where applicable, and a CI runner configuration that executes the collection on every deployment to staging with a pass/fail gate.
