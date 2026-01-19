# AI Tools for Research

**Get AI help conducting research, finding sources, and documenting findings.**

This guide covers the AI tools for anyone doing research at ShipitSmarter - whether it's market research, technical research, competitive analysis, or exploring new ideas.

---

## Quick Setup

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Then restart your terminal. Done!

---

## Your Main Tool: /research

The `/research` command is your primary research assistant. It:

1. Searches the web for relevant information
2. Checks our Notion knowledge base for existing notes
3. Checks memory for previous research on similar topics
4. Creates a structured document with sources
5. Stores key findings for future reference

**Basic usage:**
```
/research <topic>
```

**Examples:**
```
/research MongoDB Atlas pricing for small teams

/research last-mile delivery trends Europe 2025

/research comparing Kafka vs RabbitMQ for event streaming

/research GDPR requirements for tracking data retention
```

---

## Research Output

Research documents are saved to `research/<project>/` and include:

```markdown
---
topic: Your Topic
date: 2026-01-19
project: project-name
sources_count: 5
status: draft
tags: [relevant, tags]
---

## Summary
2-3 paragraph executive summary

## Key Findings
1. Main point one
2. Main point two
3. Main point three

## Detailed Analysis
Organized by subtopic...

## Sources
| Source | Key Contribution |
|--------|-----------------|
| URL 1  | What we learned |
| URL 2  | What we learned |

## Questions for Further Research
- [ ] Open question 1
- [ ] Open question 2
```

---

## Research Workflow

### 1. Start with a Clear Question

```
/research what authentication methods do major carriers support for API access?
```

Be specific. "Carrier APIs" is too broad. "DHL Express API rate limits" is better.

### 2. Review and Refine

After the initial research:

```
The research mentions OAuth 2.0 but doesn't cover token refresh patterns.
Can you dig deeper into that?
```

### 3. Fill in Gaps

```
The sources are mostly from 2023. Can you find more recent information?

None of the sources cover European carriers. Research PostNL and DPD specifically.
```

### 4. Connect to Action

```
Based on this research, what recommendations should we make?

Create a decision document comparing the options we found.
```

---

## Types of Research

### Technical Research

```
/research best practices for implementing retry logic in distributed systems

/research comparing Vue 3 state management options: Pinia vs Vuex vs composables

/research container orchestration patterns for microservices
```

### Market Research

```
/research European TMS market size and growth projections

/research what features do mid-market 3PLs prioritize in shipping software?

/research sustainability initiatives in last-mile delivery
```

### Competitive Research

```
/research Sendcloud's pricing model and target customer segments

/research how does Shippo handle multi-carrier rate shopping?

/research AfterShip vs Parcel Perform feature comparison
```

### Regulatory/Compliance Research

```
/research customs documentation requirements for EU-UK shipments

/research data retention requirements for shipping records in Netherlands

/research carrier liability regulations for lost parcels in EU
```

### User Research

```
/research UX best practices for shipment tracking pages

/research how do users prefer to receive delivery notifications?

/research accessibility requirements for logistics dashboards
```

---

## Tips for Better Research

### Be Specific

```
Good: "What are the rate limits for the DHL Express Tracking API?"
Bad: "Tell me about DHL"
```

### Provide Context

```
/research Kubernetes operators for MongoDB

Context: We're evaluating whether to use Atlas Operator or 
Community Operator for our self-hosted MongoDB deployment on AKS.
```

### Ask for Primary Sources

```
/research carrier tracking webhook best practices

Prioritize official documentation and engineering blogs over SEO content.
```

### Request Comparisons

```
/research comparing RabbitMQ vs Kafka vs Azure Service Bus
for our event-driven architecture needs

We need: high throughput, exactly-once delivery, easy operations
```

### Specify the Audience

```
/research MongoDB backup strategies

This is for a decision document for the infrastructure team,
so include operational complexity and cost considerations.
```

---

## Managing Research

### Finding Previous Research

```
Have we done research on carrier API authentication before?

What do we know about DHL integrations from previous research?
```

The AI checks memory and the `research/` folder for existing work.

### Organizing Research Projects

Create an index file for ongoing research:

```
Create an index file for our carrier-integrations research project
listing all the documents we've created so far.
```

### Updating Existing Research

```
Update the MongoDB research from January - 
there's a new Atlas pricing tier we should include.
```

---

## Existing Research Topics

Check the `research/` folder for research we've already done:

| Folder | Topics |
|--------|--------|
| `mongodb-kubernetes/` | Atlas Operator, self-managed MongoDB |
| `company-context/` | ShipitSmarter overview, competitor analysis |
| `product-strategy/` | Team organization, strategy frameworks |
| `testing-strategy/` | Modern testing practices, coverage guidelines |
| `agent-skills/` | AI skill best practices, external loading |
| `github-copilot/` | Custom instructions, organization settings |

---

## When Research Isn't Enough

Sometimes you need more than web research:

### For Customer Insights
```
I need to understand how our customers actually use the tracking page.
What data should I look at in PostHog?
```

### For Internal Knowledge
```
Search Notion for previous discussions about carrier retry logic
```

### For Expert Opinions
```
Based on this research, what questions should I ask our carrier integration experts?
```

---

## Example Research Session

```
User: /research best practices for webhook retry mechanisms

AI: [Creates research document with findings]

User: Good start. The sources focus on general webhooks.
      Can you find anything specific to shipping/logistics webhooks?

AI: [Adds logistics-specific findings]

User: What about handling idempotency? That wasn't covered well.

AI: [Researches idempotency patterns, updates document]

User: Create a summary I can share with the team - 
      just the key recommendations in bullet points.

AI: [Creates concise summary]
```

---

## Getting Help

- **Research not finding good sources?** Try different keywords or ask AI to suggest alternative search terms
- **Need to verify information?** Ask "What are the primary sources for this claim?"
- **Want to go deeper?** Ask follow-up questions - the AI remembers context
- **Questions?** Ask in Slack
