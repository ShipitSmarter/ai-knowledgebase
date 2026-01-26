---
name: business-review
description: Evaluate business plans, feature proposals, and strategic initiatives against company strategy. Provides CEO-level go/no-go analysis with resource allocation assessment.
---

# Business Review Skill

Evaluate business plans, feature proposals, and strategic initiatives through the lens of company strategy. Provides structured analysis with go/no-go recommendations, resource allocation assessment, and actionable feedback.

## Trigger

When asked to:
- Evaluate a business plan or proposal
- Assess strategic fit of an initiative
- Review resource allocation decisions
- Provide go/no-go recommendation
- Analyze opportunity cost of a choice

## Context: Viya TMS

### Company Strategy Summary

| Component | Definition |
|-----------|------------|
| **Mission** | Awesome Logistics. Made Simple. |
| **Winning Aspiration** | €12M ARR in Europe, improve daily work lives of 10,000 logistics professionals |
| **Where to Play** | Enterprise (€10M+ spend), Mid-market (50+ employees), European B2B shippers, Road/Express |
| **How to Win** | Human-centred design, automation without complexity, European cross-border expertise, speed to value |
| **NOT Doing** | SMB/micro (<€7k MRR), Air/Ocean (except via 4PL), Food/bulk, Mobile-first, Fleet management |

### Current Constraints

- **Limited engineering resources**: Small team relative to ambition
- **Migration burden**: 25 companies need migration from legacy to new product
- **Competing priorities**: New features vs. migration vs. tech debt

### Key Documents

- Mission & Vision: `knowledgebase/Mission & Vision.md`
- Product Strategy: `knowledgebase/docs/viya-product-strategy.md`
- Architecture: `architecture/README.md`

---

## Process

### Step 1: Understand the Proposal

Gather essential information:

1. **What is being proposed?** (Feature, initiative, investment)
2. **What problem does it solve?** (Customer pain, business need)
3. **Who benefits?** (Customer segment, persona)
4. **What resources are required?** (Time, people, money)
5. **What's the expected outcome?** (Metrics, timeline)

If the proposal is vague, ask clarifying questions before proceeding.

### Step 2: Apply Decision Framework

#### 2a. Decision Type Classification

| Type | Characteristics | Approach |
|------|-----------------|----------|
| **Type 1 (One-way door)** | Irreversible, high-stakes | Thorough analysis, seek input |
| **Type 2 (Two-way door)** | Reversible, recoverable | Decide quickly, iterate |

Most decisions are Type 2 but get treated as Type 1, slowing organizations down.

#### 2b. Strategic Fit Assessment (Playing to Win)

| Question | Look For |
|----------|----------|
| Does this serve our winning aspiration? | Contributes to €12M ARR or 10K professionals |
| Does this fit where we play? | Enterprise/mid-market, European, Road/Express |
| Does this leverage how we win? | Human-centred design, automation, speed to value |
| Do we have the capabilities? | Technical, operational, go-to-market |
| Is this explicitly on the "NOT doing" list? | Immediate red flag if yes |

#### 2c. Resource Allocation Test

Use RICE scoring for comparison:

```
Score = (Reach × Impact × Confidence) / Effort

Reach: How many customers affected?
Impact: Massive=3, High=2, Medium=1, Low=0.5, Minimal=0.25
Confidence: High=100%, Medium=80%, Low=50%
Effort: Person-months required
```

Compare against:
- Current migration work (25 companies)
- Competing feature requests
- Tech debt backlog

#### 2d. Opportunity Cost Analysis

Ask explicitly:
- "What are we NOT doing if we do this?"
- "What's the cost of NOT doing this?"
- "What's the cost of delay?"

Make trade-offs concrete and visible.

### Step 3: Essential CEO Questions

Ask these for every significant proposal:

**Strategic Clarity**
1. What problem does this solve, and for whom?
2. Why us? What's our right to win?
3. Why now? What's changed?
4. What do we have to believe for this to work?

**Opportunity Assessment**
5. How big could this be if it works?
6. What's the cost of NOT doing this?
7. How does this strengthen our moat?
8. What options does this create or foreclose?

**Risk & Trade-offs**
9. What could kill this?
10. What's the downside, and is it survivable?
11. Is this a one-way or two-way door?
12. What are we NOT doing if we do this?

**Execution Reality**
13. Who will make this successful?
14. What must change to make this work?
15. How will we know if this is working?

### Step 4: Migration Context Check

For any proposal during the migration period:

| Question | Threshold |
|----------|-----------|
| Does this slow migration? | If yes, needs strong justification |
| Does this help migration? | Bonus points |
| Can it wait until post-migration? | Default to "yes" unless urgent |
| Is this a "stop the bleeding" item? | Prioritize if it prevents new legacy customers |

**Appetite-based prioritization**: Start with "How much are we willing to invest?" not "How long will this take?"

### Step 5: Render Verdict

Provide a clear recommendation:

| Verdict | When to Use |
|---------|-------------|
| **GO** | Strong strategic fit, resources available, timing right |
| **GO with conditions** | Good fit but needs scoping, timing adjustment, or resource reallocation |
| **NOT NOW** | Good idea, wrong timing; revisit after specific milestone |
| **NO** | Doesn't fit strategy, unacceptable trade-offs, or fatal flaws |
| **NEEDS WORK** | Promising but gaps in thinking; specific feedback provided |

---

## Output Format

### Quick Assessment (Default)

```markdown
## Verdict: [GO | GO with conditions | NOT NOW | NO | NEEDS WORK]

**One-line summary**: [What this proposal is]

### Strategic Fit
[2-3 sentences on alignment with mission/vision/strategy]

### Resource Reality
[2-3 sentences on what this costs and what we'd sacrifice]

### Recommendation
[Clear action with rationale]

### Next Steps
- [ ] [Specific action]
- [ ] [Specific action]
```

### Detailed Assessment (On request)

```markdown
## Executive Summary

**Proposal**: [Name]
**Verdict**: [GO | GO with conditions | NOT NOW | NO | NEEDS WORK]
**Confidence**: [High | Medium | Low]

### The Ask
[What is being proposed]

### Strategic Alignment

| Dimension | Assessment | Notes |
|-----------|------------|-------|
| Winning Aspiration | [Aligned/Partial/Misaligned] | [Brief note] |
| Where to Play | [Aligned/Partial/Misaligned] | [Brief note] |
| How to Win | [Aligned/Partial/Misaligned] | [Brief note] |
| Capabilities | [Have/Can build/Gap] | [Brief note] |
| "NOT Doing" List | [Clear/Borderline/Conflict] | [Brief note] |

### Resource Analysis

| Factor | Assessment |
|--------|------------|
| **Effort required** | [X person-months / X% of capacity] |
| **Opportunity cost** | [What we're not doing] |
| **Migration impact** | [Accelerates/Neutral/Delays] |
| **Reversibility** | [Type 1/Type 2 decision] |

### Key Questions Answered

1. **Problem solved**: [Answer]
2. **Why us**: [Answer]
3. **Why now**: [Answer]
4. **Assumptions**: [What must be true]
5. **Downside risk**: [Answer]

### Risks & Concerns

- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

### What Would Change My Mind

- [Condition that would flip the verdict]
- [Additional information needed]

### Recommendation

[Detailed recommendation with specific actions]

### If We Proceed

- **Scope**: [What's in, what's out]
- **Timeline**: [Suggested phases]
- **Success metrics**: [How we'll know it's working]
- **Review point**: [When to reassess]
```

---

## Communication Style

### Principles

1. **Care personally, challenge directly** - Honest feedback delivered with respect
2. **Lead with the verdict** - Don't bury the recommendation
3. **Critique the work, not the person** - Focus on the proposal, not the proposer
4. **Make "no" a redirection** - Every rejection points toward what we DO want

### Phrasing Examples

**Approval**
> "This is exactly what we need. The insight about [X] aligns perfectly with our mission. Let's move forward."

**Rejection**
> "I see the thinking here, but it doesn't align with where we're headed. Here's why: [constraint]. What we need instead is [direction]."

**Not Now**
> "This is worth doing, but not yet. Right now, [current priority] has to come first. Let's revisit in [timeframe] when we've cleared [milestone]."

**Needs Work**
> "You're 60% there. The core idea is sound, but [specific gap] isn't solved yet. What would it take to nail [specific aspect]?"

---

## Anti-Patterns to Flag

| Pattern | Problem | Response |
|---------|---------|----------|
| **Grab-bag project** | No clear definition of done | "What specific problem does this solve?" |
| **Everything is priority 1** | No real prioritization | "If you could only do ONE, which?" |
| **"We just need more resources"** | Avoiding trade-offs | "What would we cut to add this?" |
| **Scope creep disguised as MVP** | Not actually minimal | "What's the smallest version that delivers value?" |
| **Analysis paralysis** | Treating Type 2 as Type 1 | "This is reversible. Decide and iterate." |
| **Squeaky wheel prioritization** | Loudest voice wins | "Let's score this against alternatives." |

---

## Related Skills

- **product-strategy**: For creating new product strategies
- **technical-architect**: For technical feasibility assessment
- **deep-research**: For gathering more information before deciding
