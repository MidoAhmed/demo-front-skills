---
name: code-review
description: Review frontend pull requests, diffs, and proposed code changes for correctness, regressions, React and TypeScript issues, architecture, maintainability, performance, accessibility, security, and test quality.
---

# Code Review

## Purpose

Perform a structured, evidence-based review of the requested code changes.

The goal is to identify meaningful defects, regression risks, architectural problems, maintainability issues, and test gaps.

Do not modify the code unless explicitly requested.

Do not report an issue only because another implementation would be preferable. Report concrete problems, meaningful risks, or violations of established project requirements and conventions.

---

## Workflow

### 1. Understand the intended change

Before reviewing the implementation:

1. Read the Jira ticket, specification, acceptance criteria, or PR description when available.
2. Identify the intended behavior.
3. Identify explicit requirements and constraints.
4. Identify the expected scope of the change.
5. Identify existing behavior that must remain unchanged.

If the intended behavior cannot be determined, state the limitation rather than guessing.

---

### 2. Inspect the change

Review:

- Pull request description
- Git diff
- Changed files
- Relevant surrounding code
- Related components
- Related hooks
- Services and API calls
- Types and interfaces
- State management
- Existing tests

Do not limit the review to changed lines when surrounding code is necessary to determine correctness.

Avoid exploring unrelated parts of the codebase unless they are relevant to the change.

---

### 3. Understand the existing behavior

Before judging the implementation, determine:

- How the affected feature currently works
- Where the relevant data comes from
- How the data flows through the application
- Which components consume the affected data
- Which state is local versus shared
- Which abstractions are involved
- Which existing patterns are used
- Which tests protect the existing behavior

Prefer existing project patterns and abstractions over introducing unnecessary new ones.

---

### 4. Review functional correctness

Check for:

- Incorrect business logic
- Missing conditions
- Incorrect conditional rendering
- Incorrect state transitions
- Incorrect data transformations
- Incorrect API usage
- Incorrect handling of empty data
- Incorrect null or undefined handling
- Incorrect loading states
- Incorrect error handling
- Incorrect asynchronous behavior
- Incorrect event handling
- Incorrect navigation
- Incorrect permission or authorization behavior

Check relevant edge cases.

Do not invent unrealistic scenarios solely to increase the number of findings.

---

### 5. Review React correctness

Check for meaningful React-specific problems, including:

- Incorrect hook usage
- Incorrect effect dependencies
- Stale closures
- Unnecessary effects
- Effects used for derived state
- Unnecessary state
- Incorrect state synchronization
- Unstable list keys
- Incorrect list rendering
- Incorrect memoization
- Context misuse
- Incorrect ref usage
- Async race conditions
- Missing cleanup
- Controlled/uncontrolled component problems
- Unnecessary renders

Do not recommend `useMemo`, `useCallback`, memoization, or effects merely as stylistic preferences.

Report them when there is a concrete correctness or meaningful performance reason.

---

### 6. Review TypeScript correctness

Check for:

- Incorrect types
- Unsafe type assertions
- Unnecessary `any`
- Incorrect nullable handling
- Incorrect type narrowing
- Incorrect generic usage
- API/domain type mismatches
- Missing exhaustive handling
- Runtime assumptions that are not represented by types
- Types that hide rather than prevent errors

Prefer type-safe solutions over suppressing compiler errors.

---

### 7. Review architecture and maintainability

Check whether the change follows the existing application architecture.

Look for:

- Logic placed in the wrong layer
- Components responsible for unrelated concerns
- Duplicated business logic
- Duplicated data transformation logic
- Inappropriate coupling
- Unnecessary dependencies
- Bypassing established abstractions
- Broken separation of concerns
- Unnecessary complexity
- Failure to reuse relevant existing functionality

Do not impose a different architecture merely because it is theoretically cleaner.

Judge the change against the existing architecture and project conventions.

---

### 8. Review performance

Look for meaningful risks such as:

- Unnecessary network requests
- Duplicate requests
- Excessive rendering
- Expensive work during rendering
- Inefficient transformations
- Missing virtualization for clearly large collections
- Excessive state updates
- Incorrect caching behavior
- Significant bundle-size impact
- Unnecessary dependencies

Only report performance concerns when there is a reasonable technical basis.

---

### 9. Review error and edge-case handling

Consider relevant scenarios:

- Empty results
- Missing data
- Null or undefined values
- API failures
- Network failures
- Slow responses
- Concurrent requests
- Repeated user actions
- Invalid input
- Permission changes
- Session expiration
- Partial data

Only include scenarios relevant to the changed functionality.

---

### 10. Review security and accessibility

When relevant to the change, check for security and accessibility problems.

Security areas include:

- Unsafe handling of user-controlled data
- Injection risks
- Sensitive data exposure
- Incorrect authorization assumptions
- Unsafe URL handling
- Authentication/session problems

Accessibility areas include:

- Missing accessible names
- Incorrect semantic elements
- Keyboard accessibility
- Focus management
- Incorrect ARIA usage
- Form accessibility
- Relevant error announcements

Only report issues supported by the changed functionality.

---

### 11. Review tests

Determine whether the change is adequately protected by tests.

Review:

- Existing tests
- New tests
- Modified tests
- Missing important scenarios
- Incorrect assertions
- Tests coupled to implementation details
- Missing relevant loading/error/empty states
- Missing regression coverage

Do not require tests for every line of code.

Focus on whether important behavior and risks introduced by the change are adequately covered.

---

### 12. Analyze regression risk

Identify existing functionality that could be affected.

Consider:

- Shared components
- Shared hooks
- Shared utilities
- Shared state
- API contracts
- Data transformations
- Navigation
- Permissions
- Forms
- Related user workflows

Distinguish between:

- Confirmed regression
- Likely regression risk
- Theoretical possibility

Never present a theoretical possibility as a confirmed defect.

---

### 13. Validate findings

Before reporting a finding:

1. Verify it against the actual code.
2. Confirm that the behavior is possible.
3. Check whether existing code already prevents the issue.
4. Check whether the behavior is intentional according to the specification.
5. Determine the actual impact.
6. Remove duplicate findings.

If evidence is insufficient, do not report the issue as a definite defect.

---

# Finding Severity

Use:

- **Critical** — major production impact, security issue, data loss, or widespread failure
- **High** — significant correctness, regression, security, or reliability issue
- **Medium** — meaningful defect or maintainability problem
- **Low** — minor issue with limited impact
- **Suggestion** — optional improvement that is not required for correctness

Do not inflate severity.

Keep suggestions separate from actual defects.

---

# Finding Format

For each substantive finding provide:

- Severity
- Location
- Problem
- Evidence
- Impact
- Recommended fix

Example:

### High — Duplicate API request

**Location:** `UserList.tsx:42`

**Problem**

The effect can execute repeatedly because one of its dependencies is recreated on each render.

**Evidence**

The dependency is created during rendering and is used directly by the effect.

**Impact**

The component can issue unnecessary API requests and produce incorrect loading behavior.

**Recommended fix**

Stabilize the dependency or restructure the data-fetching logic so the request executes only when the relevant values change.

---

# Output

Structure the review as:

## Summary

Briefly describe:

- What the change does
- Overall assessment
- Main risks

## Findings

List findings ordered by severity.

Each finding must include evidence and impact.

## Test Assessment

Describe:

- What is adequately covered
- Important missing scenarios
- Recommended additional tests

## Regression Assessment

Describe:

- Potentially affected areas
- Confirmed regressions
- Areas requiring additional validation

## Positive Observations

Mention meaningful strengths when relevant.

Do not add generic praise.

## Final Assessment

Choose one:

- **Approve** — no significant issues identified
- **Approve with minor comments** — only non-blocking issues
- **Changes requested** — significant issues should be addressed
- **Unable to fully assess** — insufficient context or evidence
