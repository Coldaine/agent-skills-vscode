---
name: documentation-and-adrs
description: Records decisions and maintains documentation. Use when making significant architectural choices. Use when documenting APIs, systems, or processes. Use when teams need shared understanding of why things are built the way they are.
user-invocable: true
---

# Documentation and ADRs

## Overview

Documentation is the externalized memory of a system and the team that built it. Architecture Decision Records (ADRs) are a lightweight practice for recording the significant decisions that shaped a system — capturing not just what was decided, but why, and what alternatives were considered.

Good documentation is a multiplier: it enables new engineers to contribute faster, reduces tribal knowledge, and makes the system maintainable by people who weren't there when it was built. ADRs specifically address the "why" question that code alone can't answer.

## When to Use

- Making a significant architectural or design decision
- Choosing between competing approaches or technologies
- Establishing patterns or conventions that others will follow
- Documenting APIs for internal or external consumers
- Explaining systems that are complex, non-obvious, or frequently misunderstood
- Onboarding new team members
- Revisiting old decisions to understand their rationale

## Architecture Decision Records

### What Is an ADR?

An ADR captures a single significant decision: what was decided, why, what alternatives were considered, and what the consequences are. It's written at decision time, kept with the code, and treated as immutable once accepted — you don't change old ADRs, you write new ones that supersede them.

The key insight: **decisions are time-sensitive context**. Six months after a decision is made, the team will have forgotten why they made it. A year later, the people who made it may have moved on. ADRs preserve that context permanently.

### The Standard ADR Format

```markdown
# ADR-{number}: {Short, descriptive title}

**Date**: YYYY-MM-DD  
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-{N}

## Context

What is the situation that necessitates this decision? What forces are at play — technical constraints, business requirements, team capacity, timing? What problem are we solving?

## Decision

What are we doing? State the decision clearly and specifically.

## Alternatives Considered

### Option A: {Name}
{Describe the option, then explain why it wasn't chosen}

### Option B: {Name}
{Describe the option, then explain why it wasn't chosen}

## Consequences

**Positive:**
- {What gets better}

**Negative:**
- {What gets worse or what risks are introduced}

**Neutral:**
- {What changes without being clearly good or bad}

## References
- {Links to relevant documentation, issues, discussions}
```

### ADR Lifecycle

**Proposed**: Draft stage, open for discussion. Still under consideration.

**Accepted**: Decision has been made and is in effect. The record is now immutable — don't edit accepted ADRs, even to fix typos. (Create a new ADR to supersede it.)

**Deprecated**: The decision is no longer relevant, but nothing supersedes it. Often happens when a system is removed.

**Superseded**: A newer ADR has replaced this one. Include a reference to the superseding ADR.

### What Qualifies as an ADR?

Not every decision needs an ADR. Record decisions that:
- Are difficult to reverse
- Have significant impact on the system or team
- Required meaningful deliberation between alternatives
- Would benefit future readers to understand the reasoning

Skip ADRs for: routine implementation choices, things that are obvious in context, decisions that can be easily changed.

When in doubt, write the ADR. Short ADRs are low cost; missing decision records can be very costly.

### Where to Store ADRs

Keep ADRs close to the code they describe:

```
docs/
  decisions/
    ADR-0001-use-postgresql.md
    ADR-0002-api-versioning-strategy.md
    ADR-0003-event-driven-architecture.md
```

Alternatively, `doc/adr/` (Nat Pryce's convention) or `docs/adr/`. Pick one and be consistent.

## Documentation Principles

### Write for Future Readers

The primary audience for documentation isn't you — it's the person who reads it in six months with no context. Write with that reader in mind:

- Explain why, not just what (the code shows what; docs explain why)
- Include context that seems obvious now but won't be later
- Define acronyms and domain terms
- Link to related documents and external references

### Documentation Types and Purposes

Different documentation serves different purposes:

**Reference documentation** (APIs, data schemas, configuration): Complete, precise, always current. The authoritative source of truth. Examples: API docs, database schemas, environment variable references.

**Explanatory documentation** (architecture overviews, design docs): Helps readers build a mental model of how the system works and why it was built that way. Examples: system architecture docs, ADRs, design proposals.

**Tutorial documentation** (getting started guides, walkthroughs): Enables new users or developers to accomplish something end-to-end. Prioritizes success over comprehensiveness. Examples: onboarding guides, quickstarts, tutorials.

**Runbook documentation** (operational procedures): Guides operators through specific tasks or incidents. Examples: deployment procedures, incident response runbooks, on-call guides.

### The Documentation-Code Relationship

Documentation decays when it's not co-located with the code it describes. Best practices:

- Keep docs in the same repository as the code
- Use tools that generate reference docs from code (docstrings, OpenAPI specs, database schema tools)
- Review documentation changes in the same pull requests as code changes
- Treat outdated documentation as a bug

### The Curse of Knowledge

The biggest documentation failure mode is writing for people who already know the system. Experts forget what it was like not to know. Fight this by:

- Having non-experts review documentation
- Including documentation review in onboarding (new hires catch gaps experts don't)
- Explaining the problem being solved before the solution
- Not assuming familiarity with internal terminology or system history

## API Documentation

APIs need complete, accurate, and usable documentation:

### What to Document

- **Endpoints**: URL, method, description
- **Request**: Headers, path params, query params, request body (with types and constraints)
- **Response**: Status codes, response body structure, error formats
- **Authentication**: How to authenticate, what credentials are needed
- **Rate limits**: Limits and how to handle 429s
- **Examples**: Request/response examples for the common case and key edge cases
- **Changelog**: What changed between versions

### OpenAPI/Swagger

For REST APIs, define your API in OpenAPI format. Benefits:
- Generates interactive documentation (Swagger UI, Redoc)
- Enables client SDK generation
- Supports API testing tools
- Creates a machine-readable contract between provider and consumer

### Docstrings and Code Comments

For internal APIs and libraries:

```python
def calculate_retry_delay(attempt: int, base_delay: float = 1.0) -> float:
    """
    Calculate exponential backoff delay for retry attempts.
    
    Uses full jitter to avoid thundering herd:
    delay = random(0, min(cap, base * 2^attempt))
    
    Args:
        attempt: Zero-indexed retry attempt number
        base_delay: Base delay in seconds (default: 1.0)
    
    Returns:
        Delay in seconds to wait before the next retry attempt
    
    References:
        https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/
    """
```

Document: what the function does, parameters and return values, non-obvious behavior, important edge cases, and references.

## README Files

Every repository should have a README that answers:

1. **What is this?** One paragraph describing what the project does and why it exists
2. **Who uses it?** Who is the intended audience
3. **How do I run it?** Setup and local development instructions
4. **How do I use it?** Basic usage examples
5. **How does it work?** Architecture overview (or link to one)
6. **How do I contribute?** Contribution guidelines, PR process, coding standards
7. **Who do I contact?** Ownership, support channels

Keep README files current. A README with outdated setup instructions is worse than no README — it wastes people's time and erodes trust in documentation generally.

## Documentation Maintenance

### Documentation as Code

Treat documentation with the same discipline as code:
- Review changes in pull requests
- Keep documentation in version control
- Test documentation (links work, code examples actually run)
- Have owners for documentation just as you have owners for code

### When to Update Documentation

Update documentation when:
- The behavior it describes changes
- You discover it's inaccurate or misleading
- You answer the same question twice from someone reading the docs
- You add new functionality

### Documentation Debt

Documentation debt accumulates silently. Signs you have it:
- New engineers struggle to get productive
- The same questions come up repeatedly in Slack
- People are afraid to touch certain code because they don't understand it
- "Ask Alice" is the standard answer for any question about a subsystem

Address documentation debt by scheduling dedicated time, not hoping it gets done as a side effect of feature work.

## Checklist

### For Architectural Decisions

- [ ] Is this decision significant enough to warrant an ADR?
- [ ] Have alternatives been genuinely considered (not just the chosen approach)?
- [ ] Are the reasons for the decision clearly articulated?
- [ ] Are the tradeoffs and consequences documented?
- [ ] Is the ADR stored with the code it relates to?
- [ ] Is the status accurate and current?

### For Documentation Generally

- [ ] Is this written for someone without context, not for yourself?
- [ ] Does it explain why, not just what?
- [ ] Is it co-located with the code it describes?
- [ ] Will someone be responsible for keeping it current?
- [ ] Are there code examples that actually work?
- [ ] Has it been reviewed by someone without existing context?
