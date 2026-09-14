# Code Review Checklist

Use this checklist to guide the review.

Do not mechanically check every item or report every deviation.
Only report issues that are relevant to the change and supported by evidence.

---

## 1. Finding qualification

Before reporting a finding, verify:

- There is a real or highly credible problem.
- The affected code path is reachable.
- The behavior is not already prevented elsewhere.
- The behavior is not intentional according to the requirements.
- The impact is meaningful.
- The finding is specific and actionable.
- The severity reflects the actual impact.

Avoid findings based only on:

- Personal coding preferences
- Alternative implementation preferences
- Theoretical edge cases with no realistic impact
- Micro-optimizations without measurable or credible impact
- Style differences that are not project conventions
- Speculative security concerns without an actual attack path

---

## 2. Functional correctness

Look for:

- Incorrect conditions
- Missing conditions
- Incorrect boolean logic
- Incorrect state transitions
- Incorrect data transformations
- Missing validation
- Incorrect default values
- Incorrect empty-state behavior
- Incorrect loading behavior
- Incorrect error behavior
- Incorrect navigation
- Incorrect permissions
- Incorrect API parameters
- Incorrect handling of asynchronous results

Pay particular attention to code paths involving:

- Create
- Update
- Delete
- Submit
- Cancel
- Retry
- Pagination
- Filtering
- Sorting
- Searching
- Selection
- Confirmation dialogs

---

## 3. React

### Effects

Investigate:

- Incorrect dependency arrays
- Dependencies recreated on every render
- Effects causing repeated requests
- Effects synchronizing state unnecessarily
- Effects used to calculate values that could be derived during render
- Missing cleanup
- Async race conditions
- Effects running after a component is no longer relevant

Do not flag an effect merely because it exists.

### State

Investigate:

- State duplicating existing source data
- Derived state stored unnecessarily
- State initialized from props but never synchronized correctly
- State updates based on stale values
- Multiple sources of truth
- State that should be local but is unnecessarily global
- State that should be shared but is duplicated

### Rendering

Investigate:

- Incorrect list keys
- Rendering stale data
- Incorrect conditional rendering
- Unnecessary expensive rendering
- Large lists without appropriate optimization
- Incorrect memoization
- Context causing broad unnecessary updates

Do not recommend `useMemo`, `useCallback`, or `React.memo` without a concrete reason.

### Components

Investigate:

- Components handling unrelated responsibilities
- Business logic duplicated across components
- Presentation tightly coupled to data-fetching logic when the architecture separates them
- Incorrect controlled/uncontrolled behavior
- Incorrect ref forwarding or ref usage

---

## 4. TypeScript

Look for:

- `any` hiding an actual type problem
- Unsafe type assertions
- Incorrect nullable assumptions
- Missing null/undefined handling
- Incorrect type narrowing
- Incorrect generic constraints
- API types that do not match runtime data
- Domain types mixed incorrectly with DTO types
- Missing exhaustive handling

Prefer fixing the type model over suppressing compiler errors.

Be especially careful with:

```ts
as SomeType
```
