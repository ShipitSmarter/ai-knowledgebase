---
name: research
description: Conduct online research with source attribution, Notion integration, and persistent memory. Organizes findings by project in research/ folder.
---

# Research Skill

Conduct online research on a topic with full source attribution, organized by project. Integrates with Notion knowledge base and persistent memory.

## Trigger

When user asks to research a topic or invokes this skill.

## Process

### Step 1: Check Existing Knowledge

**1a. Search Memory**
First, check opencode-mem for prior research on this topic:
```javascript
memory({ mode: "search", query: "<topic>", tags: ["research"] })
```
Note any relevant prior findings.

**1b. Search Notion**
Search the Notion knowledge base for existing notes:
```javascript
notion_search({ query: "<topic>" })
```
If relevant pages found, retrieve their content to build upon.

### Step 2: Detect Project Context

Check `research/` folder for existing projects:
```
ls research/
```

Analyze if the research topic fits an existing project:
- Look at project names and `_index.md` files
- If match found, confirm with user: "This seems related to project X. Add to that project?"
- If no match, suggest a project name based on the topic

### Step 3: Conduct Web Research

Use Google AI Search to find new information:
```javascript
google_ai_search_plus({ query: "<topic>" })
```

Gather at least 3-5 sources, prioritizing:
- Official documentation
- Academic papers
- Reputable tech blogs
- Primary sources over aggregators

### Step 4: Validate Source Quality

**Before proceeding, classify each gathered source by tier:**

| Tier | Classification | Examples |
|------|----------------|----------|
| **Tier 1** | Official documentation, peer-reviewed papers, pattern creators | MongoDB docs, RFCs, Martin Fowler |
| **Tier 2** | Vendor documentation, framework maintainers | Microsoft Learn, library official docs |
| **Tier 3** | Reputable publications, known experts, vendor blogs | Major tech blogs, conference talks |
| **Tier 4** | Community content, personal blogs, forum posts | Dev.to, Medium, Stack Overflow |

**Quality Check:**

Count sources by tier:
- Tier 1-2 (High confidence): X sources
- Tier 3-4 (Lower confidence): Y sources

**If more than 50% of sources are Tier 3-4**, pause and warn the user:

> ⚠️ **Source Quality Warning**
> 
> The gathered sources are weighted toward lower-confidence content:
> - High confidence (Tier 1-2): X sources (Y%)
> - Lower confidence (Tier 3-4): Z sources (W%)
> 
> **Lower-confidence sources:**
> | Source | Tier | Why Lower Confidence |
> |--------|------|---------------------|
> | [Source](url) | 3 | Vendor blog, potential bias |
> | [Source](url) | 4 | Personal blog, unverified |
> 
> **Options:**
> 1. Proceed anyway (findings will be flagged as lower confidence)
> 2. Search for more authoritative sources first
> 3. Narrow the topic to find more official documentation
> 
> How would you like to proceed?

**Wait for user confirmation before continuing.**

If user proceeds, add a confidence warning to the final document's frontmatter:
```yaml
confidence: low  # >50% sources are Tier 3-4
```

### Step 5: Synthesize Findings

Combine information from all sources:
- Memory (prior research context)
- Notion (existing knowledge base notes)
- Web search (new information)

Note contradictions or updates to prior understanding.

### Step 6: Create Research Document

Create file: `research/<project>/<YYYY-MM-DD>-<topic-slug>.md`

Use this template:

```markdown
---
topic: <Full Topic Title>
date: <YYYY-MM-DD>
project: <project-name>
sources_count: <number>
confidence: high | medium | low  # Based on source tier distribution
notion_refs: [<page-ids if any>]
status: draft
tags: [<relevant>, <tags>]
---

# <Topic Title>

## Summary

<2-3 paragraph executive summary of findings>

## Key Findings

1. **Finding 1**: Brief explanation
2. **Finding 2**: Brief explanation
3. **Finding 3**: Brief explanation

## Related Knowledge Base

<If Notion pages were found, list them here>
- [Notion: Page Title](notion://page-id) - How it relates

## Detailed Analysis

### <Subtopic 1>

<Detailed information organized logically>

### <Subtopic 2>

<More detailed information>

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [Title](URL) | What we learned from this source |
| 2 | [Title](URL) | What we learned from this source |
| 3 | [Title](URL) | What we learned from this source |

### Source Details

1. **[Source Title](URL)**
   - Author/Org: <if available>
   - Date: <if available>
   - Key quotes or data points

2. **[Source Title](URL)**
   - Author/Org: <if available>
   - Key quotes or data points

## Questions for Further Research

- [ ] Open question 1
- [ ] Open question 2

## Related Research

- Link to related files in this project
- Link to related projects
```

### Step 7: Store Key Findings in Memory

After creating the document, store important findings for future recall:
```javascript
memory({
  mode: "add",
  content: "Research on <topic>: <key finding summary>",
  scope: "project",
  tags: ["research", "<project-name>", "<topic-tag>"]
})
```

### Step 8: Update Project Index

If this is a new project, create `research/<project>/_index.md`:

```markdown
# <Project Name>

## Overview
<Brief description of this research project>

## Documents
| Date | Topic | Status |
|------|-------|--------|
| YYYY-MM-DD | [Topic](./file.md) | draft/reviewed/final |

## Key Insights
<Accumulated insights across all research in this project>

## Open Questions
- [ ] Question 1
- [ ] Question 2
```

If existing project, update the Documents table and Key Insights.

## Output to User

After completing research, provide:
1. Summary of what was found (including prior knowledge referenced)
2. Path to the created file
3. Count of sources used (web + Notion)
4. Any suggested follow-up research
5. Related Notion pages found (if any)

## Error Handling

If search fails:
- Try fallback search (Brave Search if Google AI fails)
- Inform user of the issue
- Suggest alternative search terms
- Offer to try different search approaches

If no relevant sources found:
- Check if Notion has any related content
- Report this to user
- Suggest broadening or narrowing the topic
- Offer related topics that might have results

## Tool Reference

| Tool | When to Use |
|------|-------------|
| `memory({ mode: "search" })` | Check prior research context |
| `notion_search()` | Search existing knowledge base |
| `google_ai_search_plus()` | Primary web search |
| `brave_search()` | Fallback web search |
| `memory({ mode: "add" })` | Store key findings for later |
