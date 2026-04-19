---
name: idea-refine
description: Refines ideas into implementable plans. Use when exploring a vague concept that needs shaping. Use when evaluating feasibility before committing resources. Use to identify hidden assumptions, risks, and the minimum viable version of an idea.
user-invocable: true
---

# Idea Refinement

## Overview

Idea refinement is the discipline of taking a vague concept and developing it into something concrete enough to decide whether and how to act on it. It sits between inspiration and execution — a phase where ideas are stress-tested, assumptions are surfaced, and the shape of the possible becomes clearer.

Good refinement neither kills ideas with premature skepticism nor rushes them into execution before they're ready. It's a productive middle ground: rigorous enough to find real problems, generative enough to find real solutions.

## When to Use

- An idea sounds good but nobody can quite articulate what it is
- A concept is compelling but you're not sure if it's feasible
- Before committing resources to something that's still vague
- When multiple versions of an idea exist and you need to choose
- When the same idea keeps coming up but never gets traction
- Before writing a spec, proposal, or business case

## Core Principles

### Separate Exploration from Evaluation

The fastest way to kill an idea is to evaluate it while you're still exploring it. When someone proposes something new, the first response should be curiosity, not judgment. Spend time understanding what the idea is trying to accomplish before assessing whether it works.

This doesn't mean suspending critical thinking forever — it means sequencing it. First: understand. Second: evaluate.

### Name the Problem Before the Solution

Most ideas arrive as solutions. "We should build X" or "we should do Y." Before engaging with the solution, make sure the problem is clear: what situation is this addressing? Who experiences it? How often? What's the cost of not solving it?

Solutions without well-understood problems have a high failure rate — not because the solution was bad, but because it was solving the wrong problem.

### Make Assumptions Explicit

Every idea rests on assumptions. Some are load-bearing: if they're wrong, the whole idea fails. Others are incidental. Good refinement surfaces assumptions and sorts them by importance, then figures out which ones can be tested cheaply.

### Find the Minimum Viable Version

The minimum viable version of an idea is the smallest thing that would meaningfully test whether the idea works. It's not a prototype or a demo — it's a version with real users doing real things. Finding the MVP of an idea focuses energy and shortens the feedback loop.

### Distinguish Opinion from Evidence

During refinement, you'll encounter assertions presented as facts. "Users want this." "This would be faster." "Nobody does it that way." Ask: what's the basis for that claim? Is it an assumption, an inference, direct observation, or measured data? The strength of a claim should match its evidential basis.

## The Refinement Process

### Phase 1: Understand the Idea

Before anything else, make sure everyone understands what's being proposed:

**Articulation**: Can the proposer state the idea in 2-3 sentences? If not, it may not be formed enough to refine yet.

**Core intent**: What problem does this solve? Who does it help? What outcome does it produce?

**Origin**: Where did this idea come from? User feedback? Internal observation? Competitive pressure? The origin often reveals what assumptions it's built on.

### Phase 2: Map the Assumptions

Ideas rely on assumptions about users, technology, business, and environment. Surface them:

- What does this assume about user behavior or preferences?
- What does it assume about technical feasibility?
- What does it assume about available resources (time, money, people)?
- What does it assume about the market or competitive environment?
- What does it assume about organizational capabilities?

Rank by importance: which assumptions, if wrong, would invalidate the whole idea? Those are the ones to test first.

### Phase 3: Stress Test

Productively challenge the idea:

**Reverse it**: What if the opposite were true? What if users actually *don't* want this? What if the problem we're solving doesn't matter to them?

**Worst case**: If this fails, how does it fail? What's the blast radius? Can we recover?

**Best case**: If this succeeds beyond expectations, can we handle it? What breaks at 10x scale?

**The cynical view**: What's the strongest case *against* this idea? Who benefits from it not existing?

**Alternatives**: What else could solve the same problem? Why is this the right approach?

### Phase 4: Find the Minimum Viable Version

Shrink the idea to its testable core:

1. State what the idea must prove to be worth pursuing
2. Identify the minimum scope that would prove or disprove it
3. Estimate the cost of that minimum version
4. Compare the cost of testing to the cost of being wrong

If the minimum version is still very large, look for proxy tests: a simpler version that would give meaningful signal without fully building the thing.

### Phase 5: Identify Next Actions

Refinement should end with concrete direction:

- What do we know well enough to proceed?
- What uncertainties remain that are significant enough to address before proceeding?
- What's the cheapest way to resolve those uncertainties?
- What's the next concrete action?

If the answer is "we need to do more research," be specific: what research, who does it, by when, and what question does it answer?

## Facilitation

### Running a Refinement Session

For group refinement sessions:

**Setup**: Time-box the session (60-90 min). Assign a facilitator whose job is keeping the conversation productive, not contributing ideas. Ensure the idea's proposer is present.

**Ground rules**:
- No evaluating during exploration
- Questions before statements
- Separate what we know from what we assume
- No rabbit holes — park tangents for later

**Agenda**:
1. Idea articulation (10 min): Proposer states the idea; group asks clarifying questions only
2. Problem framing (15 min): Agree on the problem being solved
3. Assumption mapping (20 min): Surface and rank assumptions
4. Stress testing (20 min): Structured critique
5. Minimum viable version (15 min): Find the smallest testable form
6. Next actions (10 min): Who does what by when

### Common Facilitation Challenges

**The idea getting shot down too fast**: Enforce the exploration phase. Defer evaluation.

**The idea never getting evaluated**: Set a timer for the exploration phase and move on.

**Tangents that consume the session**: Use a parking lot — write tangents on a board and explicitly set them aside.

**HiPPO effect** (Highest Paid Person's Opinion): Facilitate blind rounds where ideas are evaluated before authorship is revealed. Or have senior people speak last.

**Groupthink**: Devil's advocate role, explicitly assigned. Pre-mortem ("assume this failed; why?").

## Evaluation Criteria

See `refinement-criteria.md` for the full rubric.

Key dimensions:
- **Desirability**: Do real people actually want this?
- **Feasibility**: Can we build it with available resources?
- **Viability**: Does it make sense economically/organizationally?
- **Clarity**: Is the idea well enough understood to act on?
- **Risk**: What's the exposure if key assumptions are wrong?

## Frameworks Reference

See `frameworks.md` for detailed frameworks including:
- Problem/Solution/Benefit triangle
- Assumption mapping matrix
- Pre-mortem analysis
- Jobs to Be Done framing
- Opportunity scoring

See `examples.md` for worked examples of ideas at different refinement stages.

## Outputs

A refined idea should produce:

**A clear problem statement**: One or two sentences describing the problem, who has it, and why it matters.

**A solution hypothesis**: What we're proposing to do and why we think it addresses the problem.

**Key assumptions**: The three to five assumptions that matter most, and how we'd test them.

**A minimum viable version**: The smallest thing worth building or testing.

**Known risks**: What could go wrong and how we'd manage it.

**Next actions**: Specific, owned, time-bound.

## Checklist

### Before Refinement

- [ ] Can the idea be stated in 2-3 sentences?
- [ ] Is there a problem it's trying to solve?
- [ ] Is the right group of people in the room?

### During Refinement

- [ ] Is the problem clear, separate from the solution?
- [ ] Have the key assumptions been named?
- [ ] Have we applied at least one stress test?
- [ ] Have we found the minimum viable version?

### After Refinement

- [ ] Do we have a clear recommendation (proceed / don't proceed / test first)?
- [ ] Are next actions specific, owned, and time-bound?
- [ ] Is there agreement on what question we're trying to answer next?
