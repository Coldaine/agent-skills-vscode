# Ideation Session Examples

These examples demonstrate idea refinement in practice, showing an idea at different stages and what productive refinement looks like.

---

## Example 1: The "AI-Powered Onboarding" Idea

### Initial State (Unrefined)

> "We should use AI to make onboarding better. Like, when a new user signs up, AI figures out what they need and guides them through it."

This is a common starting point: a direction, an intuition, but not yet an idea. Before refinement, it's unclear what problem is being solved, what "AI" is actually doing, or what success looks like.

### Refinement Round 1: Understanding

**Facilitator questions:**
- What specifically is wrong with onboarding today?
- When you say AI guides them — what does that look like?
- Who is the user in this scenario?

**What emerged:**
- Onboarding completion rate is 40%. Most drop off in the first 10 minutes.
- Drop-off analysis shows two clusters: users who bounce immediately (wrong product fit) and users who get stuck at the integrations step.
- "AI guiding them" is vague. The proposer is imagining something like an interactive tutorial that adapts to what the user actually clicks on.
- User type: B2B SaaS, the person who signed up is often not the same as the person who'll use it daily.

**Problem reframing:**
The onboarding problem isn't that users don't have guidance — there's a guided tour that 70% of users skip. The problem is that users who need integrations can't complete them without involving their IT team, who weren't part of the signup process.

**Result:** The original idea is probably solving the wrong problem. The actual problem is multi-stakeholder onboarding for technical setup steps.

### Refinement Round 2: New Direction

With the problem reframed, the group explores different solutions:

- Email sequences that bring in the IT stakeholder
- A separate "IT setup" link that can be shared
- Async onboarding where steps can be completed by different people
- Delay the integration step until the user has seen value without it

**Assumption mapping for the front-runner (shareable IT setup link):**

| Assumption | Importance | Confidence | Test method |
|-----------|-----------|-----------|-------------|
| Users know who their IT person is | High | Medium | Survey 20 users |
| IT person will act on a link from a stranger | High | Low | Send test emails |
| Integration is the primary drop-off cause | High | High | Already in data |
| Adding a step won't increase drop-off elsewhere | Medium | Low | A/B test |

**Minimum viable version:** 
Before building anything: email 50 users who dropped off at integration step. Offer to schedule a 15-min call to complete setup together. Measure how many respond and complete. If it works manually, automate.

---

## Example 2: The "Internal Knowledge Base" Idea

### Initial State

> "We need a knowledge base. People keep asking the same questions and nobody knows where to find anything."

### Refinement

**Problem articulation:**
Three symptoms identified:
1. The same questions appear in Slack repeatedly
2. Engineers can't find documentation for internal APIs
3. New hires take longer than they should to get productive

These are related but distinct problems. The group decides they're all symptoms of "documentation is inconsistently created and not discoverable."

**Assumption mapping:**

| Assumption | Verdict |
|-----------|--------|
| People will write documentation if there's a place to put it | Risky — most knowledge base projects fail because of this |
| The problem is findability, not creation | Unclear — we have a wiki, but it's not used |
| A new tool will solve this | Probably wrong — same problem as the old wiki |

**Stress test — the cynical view:**
We already have Confluence. It's not used because writing documentation is not in anyone's workflow and not incentivized. A new tool won't fix a culture/incentive problem.

**Revised direction:**
Instead of a tool, focus on workflow: make it easy to document at the moment of creation. Specific proposals:
- PRs require a docs update if they change a public API
- "Explain to me like I'm new" Slack workflow that auto-saves answers to a searchable store
- Pair new hires with an existing engineer specifically to document what's confusing

**Minimum viable version:**
For 30 days, whenever a question is answered in Slack, the answerer is prompted (via bot) to save the Q&A to a simple searchable store (Notion, Slite, or just a Google Doc). Measure whether the store gets used before investing in tooling.

---

## Example 3: The "Async-First" Work Policy

### Initial State

> "We should go async-first. Too many meetings are killing productivity."

### Refinement

**Problem articulation:**
- Engineers average 4.2 hours of meetings per day according to calendar data
- 60% of meetings have no agenda and no outcomes documented
- Survey: 73% say they don't have enough uninterrupted focus time

Problem is real and documented. Solution of "async-first" is directionally correct but vague.

**What does "async-first" actually mean?**
The group generates a definition: Default to async communication (written, recorded, or documented) for anything that doesn't require real-time decision-making. Synchronous meetings reserved for: decisions requiring discussion, relationship-building, and things that are genuinely faster in real-time.

**Key assumptions:**

| Assumption | Importance | Note |
|-----------|-----------|------|
| People will write well enough for async to work | High | Risky — async writing is a skill |
| Decisions made async are as good as ones made in meetings | High | Uncertain |
| The culture will support async without feeling disconnected | High | Unknown |
| We can identify which meetings are "necessary" | Medium | May create conflict |
| Leadership will model the behavior | High | Critical — if managers still hold lots of meetings, it won't work |

**Stress test — worst case:**
Async-first is adopted nominally but not culturally. Meetings continue, now with the added expectation that everything is also documented. Work increases, trust decreases because "async" feels like surveillance.

**Minimum viable version:**
Don't roll out a policy. Run a 6-week experiment with one team:
- Cancel all recurring meetings
- Establish async norms (response time expectations, decision-making protocols)
- Hold one weekly sync for relationship maintenance
- Measure: meeting hours, self-reported focus time, decision speed, team satisfaction

Get signal before scaling.

**Decision:** Proceed with 6-week experiment. Identify one willing team. Define success criteria upfront.

---

## Example 4: The Pricing Change Idea

### Initial State

> "We should move to usage-based pricing. Everyone's doing it and it would lower the barrier to entry."

### Refinement

**Problem framing — what problem is this solving?**

Three possible problems were identified:
1. High price is a barrier for small customers
2. Large customers feel they're not getting value relative to what they pay
3. We want to capture more value from heavy users

These point to different pricing solutions. The group tries to identify which problem is most significant.

**Evidence review:**
- Churn data shows highest churn in the first 60 days — but price isn't cited as a reason. Fit and complexity are.
- Sales cycle data shows enterprise deals are often won on price after negotiation — not lost on price
- No data on usage distribution (how many users would pay more vs. less under usage-based pricing)

**Key gap:** We don't know our usage distribution. If 80% of customers use < 20% of the average, they'd pay less under usage-based pricing — revenue would drop, not grow.

**Assumptions that must be true:**
1. Usage-based pricing increases acquisition (customers who wouldn't sign up at flat rate will sign up at usage rate)
2. Revenue impact is positive (high-usage customers pay significantly more; low-usage customers churn less because they feel they're getting value)
3. The sales motion and billing infrastructure can support it

**Minimum viable version before committing:**
- Analyze usage data: what's the distribution? Under usage-based pricing at X/unit, what would current customers have paid?
- Model the revenue impact under different assumptions
- Talk to 10 churned customers about whether price was a factor
- Talk to 10 prospects who didn't convert — same question

**Decision:** Don't proceed to pricing change yet. Run the analysis (2 weeks, one analyst). Reconvene with data.

---

## Example 5: A Well-Refined Idea

This example shows what a fully refined idea looks like as an output document.

---

**Idea:** Dedicated customer success check-ins for accounts in their first 90 days

**Problem statement:**  
New accounts that don't reach a key activation milestone (3 active users + first export) within 60 days have an 80% churn rate at 6 months. We currently have no structured intervention during this period.

**Solution hypothesis:**  
A structured check-in program (day 7, day 30, day 60) with a dedicated CSM for accounts above $500 MRR will increase 60-day activation rates, reducing 6-month churn.

**Key assumptions:**
1. Accounts that aren't activating are willing to spend time on check-ins (they want to succeed, they're just stuck)
2. Check-ins can identify and resolve blockers, not just surface them
3. The activation milestone (3 users + first export) predicts retention — this is supported by cohort data
4. We can staff this without hiring (current CSM team has capacity if accounts below $500 MRR are excluded)

**Minimum viable version:**  
For 60 days, manually run the check-in program with 20 accounts ($500+ MRR, signed up in last 2 weeks). CSM owns the relationship and conducts all three check-ins. Track activation rate vs. control group (similar accounts that don't get check-ins).

**Known risks:**
- If check-ins surface blockers CSM can't resolve, it may increase frustration rather than activation
- Capacity assumption may be wrong — monitor CSM workload weekly
- Control group comparison may be confounded if CSMs informally help control group too

**Next actions:**
- [Ops, this week] Pull list of eligible accounts for pilot
- [CSM lead, this week] Identify which CSM will own pilot; define check-in agenda
- [Product, 2 weeks] Define activation milestone in analytics so it's trackable
- [CSM lead, day 60] Present activation data vs. control

**Recommendation:** Proceed with pilot.

---

## Common Patterns in These Examples

**The problem is almost always different from the original framing.**
In the onboarding example, the proposed solution (AI guidance) was solving the wrong problem. In the knowledge base example, the problem was cultural, not tooling. Refinement consistently reveals that the first framing is incomplete.

**Minimum viable versions are usually much smaller than people expect.**
The check-in program doesn't require CRM integration, automated scheduling, or a new CSM role. It requires one person doing manual outreach to 20 accounts. The pricing change doesn't require new billing infrastructure — it requires a spreadsheet analysis.

**Data gaps are better discovered early.**
The pricing example is a good case: rather than debating assumptions about customer behavior, the refinement process revealed a key data gap (usage distribution). Getting that data is a 2-week, low-cost activity. Discovering the gap after building a new pricing tier would be much more expensive.

**Recommendations have to be specific.**
"Do more research" is not an action. "Pull usage data and model revenue impact under three pricing scenarios; present findings in 2 weeks" is an action.
