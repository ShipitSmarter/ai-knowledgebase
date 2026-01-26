# AI Tools for Product

**Get AI help with strategy, documentation, user research, and competitive analysis.**

This guide covers the AI tools for product managers, product owners, and anyone doing product work at ShipitSmarter.

---

## Quick Setup

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Then restart your terminal. Done!

---

## Your Main Tools

### Product Strategy

The `/product-strategy` command helps you create strategy documents using the Playing to Win framework.

```
/product-strategy
```

This guides you through:
- Winning Aspiration
- Where to Play
- How to Win
- Capabilities Required
- Management Systems

**Example:**
```
/product-strategy for the Track & Trace team
```

### Product Documentation

The `/document` command helps write user-facing documentation for Viya features.

```
/document the shipment filtering feature

/document how to set up carrier rate cards
```

### Research

The `/research` command finds information and creates documented reports with sources.

```
/research last-mile delivery trends in European e-commerce 2025

/research competitor pricing models for TMS platforms
```

### Competitive Analysis

The `competitive-ads-extractor` skill analyzes competitor advertising and messaging.

```
Analyze the messaging on this competitor's website: [paste URL]

What positioning do our competitors use for multi-carrier shipping?
```

---

## Common Workflows

### Writing a Feature Spec

1. **Research the problem:**
   ```
   /research best practices for delivery time slot selection UX
   ```

2. **Create user stories:**
   ```
   Write user stories for delivery time slot selection from the perspective of:
   - The end consumer (receiver)
   - The logistics manager configuring options
   - The warehouse worker planning dispatch
   ```

3. **Define acceptance criteria:**
   ```
   What acceptance criteria should we have for the time slot feature?
   Consider edge cases and error scenarios.
   ```

4. **Create the issue:**
   ```
   Create an issue for: Delivery time slot selection for consumers
   
   Include the user story and acceptance criteria.
   Link to the research document.
   ```

### Creating Strategy Documents

1. **Start with the template:**
   ```
   /product-strategy for the Shipping Experience team
   ```

2. **Refine with context:**
   ```
   Here's our current situation: [describe market position, challenges]
   
   Update the Where to Play section to focus on mid-market 3PLs
   ```

3. **Validate choices:**
   ```
   What are the risks of this strategy? 
   What would need to be true for this to succeed?
   ```

### Understanding Users

```
Based on our persona for Logistics Managers, what are their top 3 pain points
when managing multi-carrier shipments?

What jobs-to-be-done should we focus on for warehouse workers?
```

The AI knows our personas (see `knowledgebase/personas/`).

### Competitive Analysis

```
/research what features do Sendcloud and Shippo emphasize for SMB customers?

Compare our Track & Trace capabilities with Parcel Perform and AfterShip
```

---

## Creating Issues the Right Way

When you need engineering work done:

```
Create an issue for: Add bulk shipment label printing

Focus on the user outcome, not the technical implementation.
```

**Key principle:** ONE issue per user-visible outcome. Implementation details go in a branch plan (PLAN.md), not fragmented across many issues.

**Good:**
- "Users can print labels for multiple shipments at once"

**Bad (too granular):**
- "Add print button"
- "Create PDF generation service"
- "Add batch selection UI"

---

## Documentation Workflow

### For New Features

```
/document the new bulk label printing feature

Include:
- Who it's for
- How to access it
- Step-by-step instructions
- Common questions
```

### For Existing Features

```
Review our documentation for rate card management.
What's missing or unclear?
```

### For Release Notes

```
Write release notes for these changes:
- Added date range filter to consignment list
- Fixed tracking status not updating for PostNL
- Improved performance on shipment overview page
```

---

## Tips for Better Results

### Provide Business Context

```
Good: "We're targeting mid-market 3PLs who manage 10-50 carriers.
       Their main pain point is manual carrier onboarding."
Bad: "Write a strategy for 3PLs"
```

### Reference Our Personas

```
"From the perspective of the Logistics Manager persona, 
what problems does this feature solve?"
```

### Ask for Trade-offs

```
"If we can only do one of these features this quarter, 
which has the biggest impact and why?"
```

### Request Specific Formats

```
"Create a one-pager I can share with stakeholders"

"Summarize this in 3 bullet points for the exec team"
```

---

## Useful Prompts

### For Discovery
```
What questions should I ask customers to validate this feature idea?

What metrics would tell us if this feature is successful?
```

### For Prioritization
```
Help me create a RICE score for these 5 features:
[list features]

What's the opportunity cost of delaying the carrier onboarding improvements?
```

### For Communication
```
Write a Slack announcement for the new bulk printing feature.
Keep it brief and focus on user benefits.

Create talking points for presenting this strategy to the leadership team.
```

### For Analysis
```
Here's feedback from 10 customer interviews about tracking.
What themes emerge? What should we prioritize?
[paste or summarize feedback]
```

---

## Where Things Live

| What | Where |
|------|-------|
| Strategy documents | `research/product-strategy/` |
| Research findings | `research/<topic>/` |
| Personas | `knowledgebase/personas/` |
| Company context | `knowledgebase/` |

---

## Getting Help

- **Setup issues?** Run `echo $OPENCODE_CONFIG_DIR` - should show a path
- **Need a new skill?** Create an issue or talk to the team
- **Questions?** Ask in Slack
