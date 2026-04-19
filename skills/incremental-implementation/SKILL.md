---
name: incremental-implementation
description: Implements features incrementally and safely. Use when building complex features that touch many parts of a system. Use to minimize risk while making progress. Use when you need to ship working software continuously rather than completing a large feature all at once.
user-invocable: true
---

# Incremental Implementation

## Overview

Incremental implementation is the practice of building software in small, independently releasable steps rather than large, all-at-once changes. Each step produces working software, moves the system toward the goal, and can be shipped without waiting for everything else to be done.

The alternative — building everything and shipping it all at once — is higher risk, slower to get feedback, and harder to debug when things go wrong. Incremental implementation distributes the risk, accelerates learning, and keeps software continuously deliverable.

## When to Use

- Building features that touch many parts of a codebase
- Migrating from one system, pattern, or technology to another
- Implementing requirements that aren't fully defined yet
- Any change large enough to take more than a day or two
- When you need to maintain production reliability while making significant changes

## Core Principles

### Always Be Shippable

Every commit should leave the codebase in a releasable state. This means: tests pass, the application starts, nothing is broken for end users. Work-in-progress is allowed behind feature flags — the code is deployed, but the feature isn't exposed yet.

If your branch is unreleasable for more than a few hours, something has gone wrong with your incrementalization.

### Small Steps Are Faster

Counter-intuitively, working in small steps is usually faster than working in large ones. Small steps are easier to review, easier to debug, and don't accumulate merge conflicts. Large steps block other work, are hard to review thoroughly, and when something goes wrong, the blast radius is larger.

### Separate Concerns in Time

Large changes usually contain multiple types of work: infrastructure, refactoring, business logic, UI changes, tests. Separate these into distinct steps. Infrastructure first, then behavior. Tests alongside behavior. Refactoring as its own step, not mixed with new functionality.

### Make It Easy to Undo

Design each step to be reversible. Feature flags make it easy to roll back behavior without a deployment. Database migrations should be reversible. Changes to external APIs should be backward-compatible before the old version is retired.

## Planning Incremental Work

### Decomposition Strategies

**Layer by layer**: Start with the data layer (schema, models), then service layer, then API, then UI. Each layer is independently testable.

**Vertical slice**: Build the thinnest possible end-to-end slice first (one user action, completely implemented), then expand. Validates the architecture before committing to full implementation.

**Strangler fig**: Add new capability alongside the old without removing the old. Once the new capability is proven, route traffic to it and retire the old implementation.

**Parallel path**: Build the new implementation alongside the old, run both with comparison testing, then switch. Low risk but requires temporary overhead of running two systems.

### Finding the First Step

The best first step:
- Is small (hours to a day)
- Produces something observable (test output, log output, UI change, API response)
- Unblocks the next step
- Doesn't break anything currently working

If you can't find a first step with these properties, the decomposition needs more work.

### The Walking Skeleton

For new systems or major features, build a "walking skeleton" first: the thinnest possible implementation of the complete system that exercises all the major components. Not feature-complete, but end-to-end. No fake components — real connections, minimal behavior.

The walking skeleton proves the architecture works before significant investment in functionality.

## Feature Flags

Feature flags (also called feature toggles) allow code to be deployed without being activated. They're essential for incremental implementation:

```python
if feature_flags.is_enabled('new_checkout_flow', user=user):
    return new_checkout(cart)
else:
    return legacy_checkout(cart)
```

### Flag Types

**Release flags**: Gate in-progress features. On by default in development, off in production until ready. Short-lived — should be removed after the feature is fully released.

**Experiment flags**: A/B test different behaviors. Control and treatment groups. Requires analysis infrastructure.

**Ops flags**: Control operational behavior (kill switches, rate limits, degraded mode). Long-lived. Used in incidents to shed load or disable problematic features.

**Permission flags**: Control access by user, role, or account. Can be long-lived. Used for beta programs, gradual rollout, or tiered access.

### Flag Hygiene

- Name flags clearly: `new_checkout_flow_v2` not `flag_42`
- Track when each flag was created and when it's expected to be removed
- Remove release flags after full rollout — flag debt is real debt
- Don't nest flags deeply — it creates untestable combinations
- Test both paths in CI

## Database Migration Patterns

Database changes are the riskiest part of incremental implementation because they can't be rolled back as easily as code.

### Expand / Contract Pattern

Never rename, retype, or drop a column in a single deployment. Use the expand/contract pattern:

**Phase 1 — Expand:**
- Add the new column/table alongside the old
- Write to both old and new
- Read from old

**Phase 2 — Migrate:**
- Backfill existing data into new structure
- Verify data consistency

**Phase 3 — Switch:**
- Read from new
- Write to both (for a period, for safety)

**Phase 4 — Contract:**
- Write to new only
- Old column/table is now unused

**Phase 5 — Cleanup:**
- Drop the old column/table in a separate deployment

This process can take multiple deployments across days or weeks. That's correct — it's safer than doing it all at once.

### Zero-Downtime Index Creation

Adding an index to a large table locks it. Use concurrent index creation:

```sql
-- PostgreSQL
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

This takes longer but doesn't block reads or writes.

### Migration Testing

- Test migrations on a copy of production data before running on production
- Measure migration time on production-sized data
- Have a rollback plan for every migration
- Don't couple application code changes and data migrations in the same deployment

## API Evolution

APIs — internal or external — need to evolve without breaking consumers.

### Backward-Compatible Changes

Safe to do in any order:
- Adding optional fields to responses
- Adding optional request parameters
- Adding new endpoints
- Relaxing validation rules

### Breaking Changes — Use the Expansion Pattern

For breaking changes:
1. Add the new version alongside the old
2. Support both versions simultaneously
3. Migrate consumers to the new version
4. Deprecate and eventually remove the old version

Never remove a field or change its semantics without going through this process.

### Consumer-Driven Contract Testing

Test that both sides of an API contract are honored. Tools like Pact allow consumers to define their expectations and providers to verify they're met — catching breaking changes before they reach production.

## Refactoring While Adding Features

The branch-by-abstraction pattern allows large refactoring while keeping the system shippable:

1. **Create abstraction**: Introduce an interface/abstraction that covers the thing you want to change
2. **Implement current behavior**: Implement the abstraction using the existing implementation
3. **Switch to abstraction**: Change all callers to use the abstraction (no behavior change)
4. **Add new implementation**: Write the new implementation behind the abstraction
5. **Gradually switch**: Move callers from old to new implementation
6. **Remove old**: Delete the old implementation

At each step, the system is fully functional and shippable.

## Observability During Incremental Rollout

When incrementally rolling out a change, you need to know if it's working:

- **Log both paths**: When using feature flags, log which path was taken
- **Metrics by variant**: Track error rates, latency, and business metrics by flag variant
- **Comparison logging**: When running old and new implementations in parallel, log when they disagree
- **Canary deployments**: Roll out to a small percentage of servers/users before full rollout
- **Define rollback criteria upfront**: Before rolling out, specify what would trigger a rollback (error rate > X, latency increase > Y)

## Common Anti-Patterns

**The big refactoring branch**: A branch that lives for weeks with a major refactoring. Merges become nightmares. Use branch-by-abstraction instead.

**Half-migrated state without a flag**: Code that's been partially migrated but has no flag guarding it. The system is in an inconsistent state that may not be obviously broken but will fail in edge cases.

**Premature optimization of step size**: Making steps so small they don't produce meaningful intermediate progress. Some features genuinely need a certain amount of work before they're testable. Find the right granularity.

**Flag proliferation**: Accumulating dozens of old flags that are "probably not needed anymore." Flags that aren't actively managed become untested code paths that can cause subtle bugs.

**Skipping the walking skeleton**: Implementing a complex feature completely in one component before connecting it end-to-end. The integration problems are found late when they're expensive to fix.

## Checklist

### Before Starting

- [ ] Is the work decomposed into steps that can each be independently shipped?
- [ ] Is there a first step that's small, observable, and doesn't break anything?
- [ ] Do large steps have feature flags to gate in-progress work?
- [ ] Are database migrations separated from application code changes?

### During Implementation

- [ ] Does the current state pass all tests and leave the system releasable?
- [ ] Is the next step clear?
- [ ] Are both paths (flag on and flag off) tested?
- [ ] Is there observability to know if the change is working in production?

### After Shipping

- [ ] Were release flags removed after the feature is fully rolled out?
- [ ] Were old implementations removed after the new one is proven?
- [ ] Were old schema columns/tables cleaned up after migration?
- [ ] Is the codebase in a cleaner state than before this work?
