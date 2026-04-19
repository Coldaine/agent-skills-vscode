---
name: deprecation-and-migration
description: Manages deprecation and migration. Use when removing old systems, APIs, or features. Use when migrating users from one implementation to another. Use when deciding whether to maintain or sunset existing code.
user-invocable: true
---

# Deprecation and Migration

## Overview

Code is a liability, not an asset. Every line of code has ongoing maintenance cost — bugs to fix, dependencies to update, security patches to apply, and new engineers to onboard. Deprecation is the discipline of removing code that no longer earns its keep, and migration is the process of moving users safely from the old to the new.

Most engineering organizations are good at building things. Few are good at removing them. This skill addresses that gap.

## When to Use

- Replacing an old system, API, or library with a new one
- Sunsetting a feature that's no longer needed
- Consolidating duplicate implementations
- Removing dead code that nobody owns but everybody depends on
- Planning the lifecycle of a new system (deprecation planning starts at design time)
- Deciding whether to maintain a legacy system or invest in migration

## Core Principles

### Code Is a Liability

Every line of code has ongoing cost: it needs tests, documentation, security patches, dependency updates, and mental overhead for anyone working nearby. The value of code is the functionality it provides, not the code itself. When the same functionality can be provided with less code, less complexity, or better abstractions — the old code should go.

### Hyrum's Law Makes Removal Hard

With a sufficient number of users of an API, it does not matter what you promise in the contract: all observable behaviors of your system will be depended on by somebody. This is Hyrum's Law, and it's why deprecation is hard. The longer something has existed, the more people depend on its exact behavior, including behaviors that were never documented or intended.

The solution isn't to avoid deprecation — it's to plan for it from the start.

### Deprecation Is a Process, Not an Event

Good deprecations happen over time with clear communication. The stages are:

1. **Announce**: Communicate what's being deprecated, when, and what the alternative is
2. **Mark**: Add deprecation notices to code (warnings, docs, `@deprecated` annotations)
3. **Migrate**: Help users move to the new approach — tooling, codemods, guides
4. **Remove**: Delete the deprecated code once migration is complete

Rushing any stage creates pain for users and erodes trust.

### Plan Deprecations at Design Time

When building new systems, decide upfront:
- What's the expected lifespan?
- What would trigger a migration?
- How will users be notified?
- What does the off-ramp look like?

A system designed with its own replacement in mind is much easier to deprecate.

## Decision Framework

### When to Deprecate vs. Maintain

Deprecate when:
- The old approach is fundamentally flawed (security, performance, correctness)
- Maintaining two approaches has higher cost than migrating
- The old approach blocks needed improvements
- Usage has dropped below a threshold where maintenance isn't justified
- A better abstraction exists and the old one creates confusion

Maintain when:
- Migration cost exceeds benefits for users and maintainers
- The old approach is stable and low-cost to maintain
- Users have legitimate reasons to stay on the old approach
- The new approach isn't proven yet

### Migration Strategies

**Big Bang**: Migrate everything at once on a fixed date. Works for small systems or when you control all consumers. High risk, fast completion.

**Parallel Run**: Run old and new systems simultaneously, compare outputs, migrate gradually. Lower risk, higher operational cost, good for critical systems.

**Strangler Fig**: Incrementally replace old functionality with new. New requests go to new system; old requests migrate over time. Old system shrinks until it can be removed. Best for large systems.

**Adapter Pattern**: Build a compatibility layer that translates between old and new interfaces. Lets users migrate at their own pace. Risk: the adapter becomes permanent.

**Feature Flags**: Gate access to old vs. new behavior behind flags. Enables gradual rollout and easy rollback. Good when behavior differences need careful validation.

## Implementation Patterns

### Deprecation Notices in Code

Make deprecation visible at the point of use:

```python
import warnings

def old_function(arg):
    warnings.warn(
        "old_function is deprecated and will be removed in v3.0. "
        "Use new_function instead: https://docs.example.com/migration",
        DeprecationWarning,
        stacklevel=2
    )
    return new_function(arg)  # delegate to new implementation
```

```typescript
/** @deprecated Use newFunction instead. Will be removed in v3.0. See migration guide. */
export function oldFunction(arg: string): Result {
  console.warn('oldFunction is deprecated...');
  return newFunction(arg);
}
```

### Semantic Versioning and Deprecation

Follow semver signals:
- **Deprecation announcements** don't require a major version bump
- **Breaking changes** (removal) require a major version bump
- Deprecated features should survive at least one minor release before removal
- Communicate the removal version clearly: "deprecated in 2.3, to be removed in 3.0"

### Migration Tooling

Reduce migration friction:
- **Codemods**: Automated code transformations (jscodeshift, libcst, ast-grep)
- **Compatibility shims**: Thin wrappers that provide the old interface via the new implementation
- **Migration guides**: Step-by-step documentation with before/after examples
- **Detection tooling**: Scripts or lint rules that identify usage of deprecated APIs

### Database Schema Migrations

Database migrations need extra care because you can't just "rename and restart":

1. **Expand**: Add new columns/tables alongside old ones
2. **Migrate data**: Backfill new columns; dual-write to old and new
3. **Switch reads**: Move reads to new schema; keep writing to both
4. **Contract**: Remove writes to old schema
5. **Cleanup**: Drop old columns/tables

Never rename or drop a column in a single deployment. Always use the expand/contract pattern.

### API Versioning and Deprecation

For external APIs:
- Version your APIs from the start (URL versioning: `/v1/`, `/v2/`, or header versioning)
- Maintain old versions for a defined period after announcing deprecation
- Use response headers to communicate deprecation: `Deprecation: true`, `Sunset: <date>`
- Log usage of deprecated endpoints to track migration progress
- Consider rate-limiting deprecated endpoints to encourage migration

## Communication Patterns

### Internal Deprecations

For code within a single team or organization:

1. Create a tracking issue with: what's deprecated, why, the alternative, migration timeline
2. Add deprecation notices in code pointing to the issue
3. Update documentation and changelogs
4. Run a codemod or provide one for simple mechanical changes
5. Set a removal date and enforce it

### External Deprecations (Public APIs)

For APIs used by external developers:

1. **Early announcement**: Give users 6-12+ months notice for significant changes
2. **Migration guide**: Detailed documentation before announcing deprecation
3. **In-product notices**: Console warnings, dashboard alerts, email notifications
4. **Sunset headers**: Machine-readable deprecation signals in API responses
5. **Support period**: Maintain the deprecated version through the sunset date
6. **Extensions**: Be willing to extend the timeline if migration is harder than expected

## Measuring Migration Progress

You can't manage what you can't measure:

- Track usage of deprecated endpoints/functions via logging and metrics
- Set targets: "80% migrated by Q3"
- Identify the largest remaining users and work with them directly
- Create dashboards showing migration progress over time
- Use feature flags to control rollout and measure impact

## Common Failure Modes

**The Permanent Deprecation**: Code marked deprecated for years with no actual removal. Deprecation warnings that nobody reads. Fix: set hard removal dates and keep them.

**The Big Bang Surprise**: Removing code without adequate notice, breaking users unexpectedly. Fix: communicate early, communicate often, maintain deprecated code through the sunset period.

**The Compatibility Trap**: The compatibility shim becomes a permanent fixture because it's "easier" than migrating. Fix: set a sunset date for the shim from the start.

**The Incomplete Migration**: Migrating 90% of usage and leaving the rest. The old system can't be removed, so its maintenance cost persists. Fix: track the long tail, work with the remaining users.

**The Missing Migration Path**: Deprecating without providing a clear alternative. Users don't know what to do. Fix: never announce a deprecation without a migration guide.

## Working with Legacy Systems

### The Rewrite Trap

Rewrites are appealing but dangerous. The second system effect: rewriters don't fully understand why the original was built the way it was, underestimate complexity, and often produce something worse. Consider:

- **Strangler fig over rewrite**: Replace incrementally instead of all at once
- **Understand before replacing**: Spend time with the old system before designing the new one
- **Preserve behavior, not code**: The goal is maintaining functionality, not preserving implementation

### Technical Debt vs. Deprecation

Not all old code should be deprecated. Technical debt is code that's harder to work with than it should be. Deprecation is for code that shouldn't exist at all. Ask:

- Is this code still providing value?
- Is the cost of maintaining it higher than the cost of migrating off it?
- Is there a clearly better alternative?

If yes to all three, deprecate. If the code just needs refactoring, that's technical debt work, not deprecation.

## Checklist

### Before Deprecating

- [ ] Understand all current users and usage patterns
- [ ] Have a clear alternative ready (or in progress)
- [ ] Write a migration guide
- [ ] Determine the deprecation timeline
- [ ] Get stakeholder buy-in on the timeline

### During Deprecation

- [ ] Add deprecation notices in code
- [ ] Update documentation and changelogs
- [ ] Announce to affected teams/users
- [ ] Create tracking for migration progress
- [ ] Provide migration tooling if the change is mechanical

### During Migration

- [ ] Monitor migration progress metrics
- [ ] Work directly with large/slow-moving users
- [ ] Keep deprecated code working through the announced sunset date
- [ ] Don't extend the sunset date unless truly necessary

### After Removal

- [ ] Delete the deprecated code completely
- [ ] Remove related tests, documentation, and tooling
- [ ] Update changelogs with the removal
- [ ] Verify no remaining references in the codebase
