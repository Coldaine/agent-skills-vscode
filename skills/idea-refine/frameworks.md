# Ideation Frameworks Reference

Use these frameworks during idea refinement sessions. They're tools, not rules — pick the ones that fit the situation.

---

## 1. Problem / Solution / Benefit Triangle

Forces clarity on all three elements before proceeding:

```
         PROBLEM
        /       \
       /         \
  SOLUTION ─── BENEFIT
```

**Problem**: What situation exists that's causing pain? Who experiences it? How often? What's the cost?

**Solution**: What are we proposing to do? Be specific — vague solutions can't be evaluated.

**Benefit**: If the solution works, what specifically gets better? For whom? By how much?

Common failure modes:
- Strong problem + solution, weak benefit (you're solving a real thing, but the improvement is marginal)
- Strong solution + benefit, weak problem (a solution looking for a problem)
- Strong problem + benefit, weak solution (the goal is right but the approach isn't)

All three must be solid before moving to execution.

---

## 2. Assumption Mapping Matrix

Surface and prioritize assumptions:

| Assumption | If wrong, idea fails? | Confidence | Cost to test |
|-----------|----------------------|-----------|-------------|
| [Assumption A] | Yes / No | High / Med / Low | [effort estimate] |
| [Assumption B] | Yes / No | High / Med / Low | [effort estimate] |

Priority order for testing:
1. **High importance + Low confidence** → Test immediately
2. **High importance + High confidence** → Document the basis for that confidence
3. **Low importance + any confidence** → Accept or defer

Don't try to test everything. Focus energy on load-bearing assumptions with high uncertainty.

---

## 3. Pre-Mortem Analysis

Project into the future: assume the idea failed. Why did it fail?

**Setup:**  
Tell the group: "It's 12 months from now. This idea was implemented, and it failed. It didn't just underperform — it was a clear failure. Why?"

Each person writes their top 3 reasons independently (before discussion). Then share and synthesize.

**What this surfaces:**
- Risks people were reluctant to raise in a forward-looking frame
- Execution risks (not just concept risks)
- Organizational and political obstacles
- Dependencies that were taken for granted

**Output:** A ranked list of risks to mitigate or accept explicitly.

---

## 4. Jobs to Be Done Frame

Expresses what the user is trying to accomplish — independent of any specific solution:

**Template:**  
_"When [situation], I want to [motivation], so I can [expected outcome]."_

**Example:**  
_"When I join a new team, I want to quickly understand how the system is structured, so I can contribute without needing to interrupt my teammates constantly."_

The JTBD frame:
- Focuses on the user's goal, not the product feature
- Reveals the full solution space (many solutions could address the same job)
- Identifies competing solutions (including non-product ones)
- Separates functional jobs ("get this done") from emotional jobs ("feel confident")

Useful when the proposed solution feels too narrow or when there's disagreement about what users want.

---

## 5. Opportunity Scoring

Developed by Tony Ulwick. Rate each opportunity on two dimensions:

**Importance**: How important is this outcome to users? (1–10)
**Satisfaction**: How well do current solutions satisfy it? (1–10)

**Opportunity score = Importance + max(Importance – Satisfaction, 0)**

Or simplified: high importance + low satisfaction = high opportunity.

| Outcome | Importance | Satisfaction | Score | Priority |
|---------|-----------|-------------|-------|----------|
| Get setup quickly | 9 | 3 | 15 | High |
| Customize workflows | 7 | 7 | 7 | Low |
| Export data easily | 8 | 5 | 11 | Medium |

This helps prioritize which problems to solve — not all important things are underserved, and not all underserved things matter.

---

## 6. The Inversion Technique

Instead of asking "how do we make this succeed?", ask "how do we guarantee this fails?"

**Steps:**
1. List everything that would ensure the idea fails
2. Review the list
3. For each item: are we accidentally doing it? How do we avoid it?

**Why it works:**  
Avoiding guaranteed failure is often easier than engineering success. The inversion frame surfaces concrete, specific risks that positive framing misses.

**Example:**  
Idea: Internal documentation program  
Guaranteed failure list:
- Make documentation optional
- Never update outdated docs
- Make the tool slow and painful to use
- Don't tell anyone it exists
- Reward people for not writing docs (by giving them more feature work instead)

→ Produces a checklist of things to explicitly not do.

---

## 7. Minimum Viable Idea Test

Find the cheapest, fastest version that would give meaningful signal:

**Step 1:** What must be true for this idea to be worth pursuing? (2-3 core hypotheses)

**Step 2:** What's the minimum thing we could do or build to test those hypotheses?

**Step 3:** What would we see if the hypothesis is true? If it's false?

**Step 4:** Can we do this test without building anything? (Wizard of Oz, concierge, fake door)

**Patterns:**
- **Fake door**: Show a button/feature that doesn't exist yet. Measure clicks. Reveals demand without building.
- **Concierge**: Manually deliver the service before automating it. Real users, real interactions, real feedback.
- **Wizard of Oz**: Build the front end; manually power the backend. User thinks it's automated; it's not.
- **Landing page**: Describe the thing, collect emails or pre-signups. Measures demand before building.

---

## Choosing the Right Framework

| Situation | Try this |
|-----------|----------|
| Unclear what problem is being solved | Problem/Solution/Benefit Triangle |
| Lots of assumptions floating around | Assumption Mapping Matrix |
| Group seems overly optimistic | Pre-Mortem Analysis |
| Debating the wrong solution space | Jobs to Be Done |
| Many problems to prioritize | Opportunity Scoring |
| Struggling to find risks | Inversion Technique |
| Not sure what to test first | Minimum Viable Idea Test |
