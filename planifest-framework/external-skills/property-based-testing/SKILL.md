---
name: property-based-testing
description: Apply property-based testing with fast-check or Hypothesis to find edge cases through generated inputs — covering invariants, model-based testing, and shrinking — use when examples cannot cover the input space.
---

# Property-Based Testing

You are a senior developer applying property-based testing to find counterexamples that hand-crafted test cases miss.

## When to Use

- Testing functions with large or complex input domains where examples cannot cover the space
- Verifying invariants: properties that must hold for all valid inputs (commutativity, idempotency, round-trip serialisation)
- Finding edge cases in parsers, serialisers, sorting algorithms, financial calculations
- Complementing example-based tests rather than replacing them

## Core Principles

**Properties Not Examples:** Example-based tests check `add(2, 3) === 5`. Property-based tests check: "for all integers a and b, `add(a, b) === add(b, a)`" (commutativity). The framework generates hundreds of random inputs to try to falsify the property.

**Generators Define the Domain:** A generator produces random values of a specific type. Constrain generators to valid input domains. For a `parseDate(str)` function, generate strings matching ISO 8601 format, not completely random bytes. Domain-constrained generators find realistic bugs faster.

**Shrinking Produces Minimal Counterexamples:** When a property fails for input `[7432, -99, 0, 234, -1]`, the shrinking algorithm automatically reduces it to the minimal failing case: `[0, -1]`. This is what makes property-based testing practical — the counterexample you see is already minimised for debugging.

**Combine with Example Tests:** Properties find unexpected counterexamples; examples document known cases and serve as specification. Use both. Properties are not a substitute for the readability of a well-named example test.

**Stateful Testing with Models:** For stateful systems (queues, databases, UI state machines), model-based testing generates sequences of random operations and checks that the real system matches a simple reference model. This finds interaction bugs that single-operation tests cannot.

## Approach

**fast-check (TypeScript/JavaScript):**
```typescript
import fc from 'fast-check';

// Property: sorting is idempotent
test('sort is idempotent', () => {
  fc.assert(
    fc.property(fc.array(fc.integer()), (arr) => {
      const sorted = sort(arr);
      expect(sort(sorted)).toEqual(sorted);
    })
  );
});

// Property: round-trip encode/decode
test('JSON round-trip', () => {
  fc.assert(
    fc.property(fc.record({ id: fc.uuid(), name: fc.string(), age: fc.nat(120) }), (user) => {
      expect(JSON.parse(JSON.stringify(user))).toEqual(user);
    })
  );
});
```

**Hypothesis (Python):**
```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_is_idempotent(lst):
    sorted_once = sorted(lst)
    sorted_twice = sorted(sorted_once)
    assert sorted_once == sorted_twice

@given(st.floats(min_value=0, max_value=1_000_000), st.floats(min_value=0.0, max_value=0.5))
def test_discount_never_exceeds_original(amount, rate):
    result = apply_discount(amount, rate)
    assert result <= amount
    assert result >= 0
```

**Common property patterns:**

- *Invariant*: A property that must always hold. `len(filter(pred, lst)) <= len(lst)` — filtering never grows a list.
- *Round-trip*: `decode(encode(x)) === x`. Applies to serialisation, compression, encryption (with key), URL encoding.
- *Commutativity*: `f(a, b) === f(b, a)`. Applies to addition, set union, string concatenation (not ordered).
- *Idempotency*: `f(f(x)) === f(x)`. Applies to normalisation, deduplication, sorting, formatting.
- *Oracle comparison*: Compare a fast optimised implementation against a slow correct reference implementation. Both should return the same results.
- *Metamorphic*: If I transform the input in a known way, the output changes in a predictable way. `sort(reverse(lst))` should equal `reverse(sort(lst))`.

**Reproducibility.** When a property fails, the framework prints the seed used for random generation. Passing `--seed=<value>` reproduces the exact failure. Store failing seeds in comments or test cases for regression.

**Model-based testing with fast-check.** Define a model (a simple JS object representing expected state) and commands (operations that transform both the model and the real system). fast-check generates random command sequences and checks model vs reality after each command.

## Common Mistakes to Avoid

- **Properties that are trivially true:** `fc.property(fc.integer(), (n) => typeof n === 'number')` — this tests JavaScript, not your code. Properties must exercise your logic.
- **Generators too broad:** Generating arbitrary strings for a URL parser produces mostly invalid URLs. The property fails on invalid input, not on bugs. Constrain generators to valid input domains, then separately test invalid input handling.
- **No custom generators for domain types:** Using `fc.string()` where you need a valid email address generates mostly garbage. Write custom generators: `validEmail = fc.emailAddress()` or compose primitives.
- **Replacing all unit tests with properties:** Properties are poor documentation and slow to run (100-1000 cases each). Keep example tests for specification and properties for deep exploration.

## Output

Property-based tests that: define meaningful invariants in the function's domain, use constrained generators that produce realistic inputs, include shrunk counterexample reproduction in failure messages, and complement (not replace) the existing example-based suite. Each property test is named after the invariant it verifies.
