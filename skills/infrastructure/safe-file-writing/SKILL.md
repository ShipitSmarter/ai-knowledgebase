---
name: safe-file-writing
description: Patterns for writing large documents without JSON serialization failures. Use when creating research documents, plans, or any file >50 lines.
---

# Safe File Writing Skill

Patterns for reliably writing large documents (research, plans, documentation) without JSON serialization failures.

## When to Use

Load this skill when:
- Creating research documents
- Writing plans or strategy documents
- Any file expected to be >50 lines
- After a write failure due to JSON parsing

## The Problem

The `write` tool serializes content as JSON. Large documents fail because:
- Unescaped special characters (newlines, quotes, backslashes)
- Content truncation mid-string
- Complex nested escaping (code blocks, YAML examples)

## The Solution: Incremental Writes

**NEVER write large documents in a single call.**

### Pattern 1: Skeleton + Edit

```
# Step 1: Write minimal skeleton
write(filePath, "# Title\n\n## Section 1\n\n## Section 2\n\n## Section 3\n")

# Step 2: Flesh out each section with edit
edit(filePath, "## Section 1", "## Section 1\n\nContent for section 1...")
edit(filePath, "## Section 2", "## Section 2\n\nContent for section 2...")
edit(filePath, "## Section 3", "## Section 3\n\nContent for section 3...")
```

### Pattern 2: Append Sections

For very long documents, build section by section:

```
# Create with first section
write(filePath, "# Title\n\n## Section 1\n\nFirst section content...")

# Append remaining sections via edit (replace end marker)
edit(filePath, "First section content...", "First section content...\n\n## Section 2\n\nSecond section...")
```

## Section Size Guidelines

| Section Type | Max Lines | If Larger |
|--------------|-----------|-----------|
| Frontmatter | 10 | Always fits |
| Summary | 20 | Split into paragraphs |
| Tables | 30 | Split table or multiple edits |
| Detailed section | 40 | Break into subsections |
| Full document | 50+ | MUST use incremental writes |

## Problematic Content

Be extra careful with:

| Content | Problem | Solution |
|---------|---------|----------|
| Code blocks | Backticks, nested quotes | Smaller sections, verify escaping |
| YAML/JSON examples | Nested escaping hell | Minimal examples, add via edit |
| URLs with params | `&`, `=`, `?` characters | Usually fine, but verify |
| Tables | Pipe characters, alignment | Build table separately, add via edit |
| User-provided content | Unknown special chars | Sanitize or add via edit |

## Recovery from Failed Write

If a write fails with "JSON Parse error":

1. **Don't retry the same call** - it will fail again
2. **Identify the problematic section** - usually near the truncation point
3. **Split into smaller pieces** - write skeleton, then edit sections
4. **Check for unescaped characters** - especially in code blocks

## Example: Research Document

```
# Step 1: Create skeleton with frontmatter
write("research/topic/2026-01-28-topic.md", 
  "---\ntopic: Topic Name\ndate: 2026-01-28\nstatus: draft\n---\n\n" +
  "# Topic Name\n\n" +
  "## Executive Summary\n\n" +
  "## Key Findings\n\n" +
  "## Detailed Analysis\n\n" +
  "## Sources\n\n")

# Step 2: Add summary
edit(filePath, "## Executive Summary", "## Executive Summary\n\nSummary paragraph 1.\n\nSummary paragraph 2.")

# Step 3: Add findings
edit(filePath, "## Key Findings", "## Key Findings\n\n1. Finding one\n2. Finding two\n3. Finding three")

# Step 4: Add analysis (may need multiple edits if long)
edit(filePath, "## Detailed Analysis", "## Detailed Analysis\n\n### Subtopic 1\n\nAnalysis...")

# Step 5: Add sources table
edit(filePath, "## Sources", "## Sources\n\n| Source | Tier | Contribution |\n|--------|------|--------------|...")
```

## Checklist Before Writing

- [ ] Document will be >50 lines? → Use incremental writes
- [ ] Contains code blocks? → Add via separate edit
- [ ] Contains tables? → Add via separate edit  
- [ ] Contains YAML/JSON examples? → Add via separate edit
- [ ] Previous write failed? → Split into smaller sections
