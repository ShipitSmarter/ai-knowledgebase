# Contributing to AI Knowledgebase

Thank you for contributing to the AI Knowledgebase! This guide will help you add and maintain content effectively.

## Table of Contents

- [Getting Started](#getting-started)
- [Content Types](#content-types)
- [Using Templates](#using-templates)
- [Style Guide](#style-guide)
- [Submission Process](#submission-process)
- [Review Process](#review-process)

## Getting Started

### Prerequisites

- Basic understanding of Markdown syntax
- Familiarity with Git and GitHub
- Knowledge of the AI tools or workflows you're documenting

### First Time Setup

1. Clone the repository
2. Create a new branch for your content
3. Choose the appropriate directory for your content
4. Copy the relevant template file

## Content Types

### Agents (`/agents`)

Document AI agent configurations, custom prompts, and setups. Use this for:
- GitHub Copilot agents
- Custom GPT configurations
- Claude projects
- Other AI assistant setups

**Template**: `agents/agent-template.md`

### Workflows (`/workflows`)

Document processes and workflows that use AI tools. Use this for:
- Development workflows
- Code review processes
- Testing strategies
- Documentation generation
- CI/CD integrations

**Template**: `workflows/workflow-template.md`

### Ideas (`/ideas`)

Capture ideas, proposals, and brainstorming. Use this for:
- Feature proposals
- Process improvements
- Experimental concepts
- Future research directions

**Template**: `ideas/idea-template.md`

### Research (`/research`)

Document research findings and analysis. Use this for:
- Product research
- Competitive analysis
- Market trends
- Technology evaluations
- User research

**Template**: `research/research-template.md`

## Using Templates

### Step-by-Step

1. **Navigate to the appropriate directory**
   ```bash
   cd agents  # or workflows, ideas, research
   ```

2. **Copy the template**
   ```bash
   cp agent-template.md my-new-agent.md
   ```

3. **Edit the file**
   - Fill in all sections
   - Remove sections that don't apply (mark as N/A if required)
   - Add additional sections if needed

4. **Use descriptive filenames**
   - Use kebab-case: `my-agent-name.md`
   - Be specific: `github-copilot-python-agent.md` not `agent1.md`
   - Include version if applicable: `api-workflow-v2.md`

## Style Guide

### Markdown Formatting

#### Headings
```markdown
# H1 - Document Title
## H2 - Major Section
### H3 - Subsection
#### H4 - Minor Section
```

#### Code Blocks
Always specify the language:
```markdown
```python
def hello():
    print("Hello, World!")
```
```

#### Lists
Use consistent formatting:
```markdown
- Unordered item
- Another item
  - Nested item

1. Ordered item
2. Second item
```

#### Links
Use descriptive link text:
```markdown
[View the Agent Documentation](./agents/README.md)
```

#### Tables
Use proper alignment:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

### Content Guidelines

#### Be Clear and Concise
- Write in simple, direct language
- Avoid jargon unless necessary
- Define acronyms on first use

#### Provide Examples
- Include real-world examples
- Show both input and output
- Demonstrate common use cases

#### Keep It Current
- Add dates to time-sensitive information
- Note version numbers for tools/software
- Update outdated content

#### Cross-Reference
- Link to related documents
- Reference dependencies
- Connect related ideas

### File Organization

#### Naming Conventions
- Use lowercase letters
- Separate words with hyphens
- Be descriptive but concise
- Examples:
  - ✅ `code-review-workflow.md`
  - ✅ `competitive-analysis-2026.md`
  - ❌ `workflow1.md`
  - ❌ `My_Agent.md`

#### Directory Structure
- Keep flat structure when possible
- Create subdirectories for related content:
  ```
  agents/
    ├── coding-agents/
    │   ├── python-agent.md
    │   └── javascript-agent.md
    └── research-agents/
        └── market-research-agent.md
  ```

## Submission Process

### 1. Create a Branch
```bash
git checkout -b feature/your-content-name
```

### 2. Add Your Content
- Copy and fill out the appropriate template
- Follow the style guide
- Add any supporting files

### 3. Commit Your Changes
```bash
git add .
git commit -m "Add: [Brief description of content]"
```

Use conventional commit prefixes:
- `Add:` for new content
- `Update:` for modifying existing content
- `Fix:` for corrections
- `Remove:` for deleted content

### 4. Push to GitHub
```bash
git push origin feature/your-content-name
```

### 5. Create a Pull Request
- Provide a clear title
- Describe what you're adding
- Mention any related issues or discussions

## Review Process

### What Reviewers Look For

1. **Completeness**
   - All required template sections filled
   - Sufficient detail and examples
   - Clear instructions or explanations

2. **Accuracy**
   - Technically correct information
   - Working examples
   - Valid links and references

3. **Clarity**
   - Easy to understand
   - Well-organized
   - Proper formatting

4. **Relevance**
   - Fits the purpose of the section
   - Useful for the team
   - Not duplicating existing content

### Responding to Feedback

- Address all review comments
- Ask questions if feedback is unclear
- Make requested changes promptly
- Re-request review after updates

## Maintenance

### Updating Existing Content

1. Check if the content is still accurate
2. Update dates and version information
3. Add new sections if relevant
4. Remove or archive outdated information

### Archiving Content

If content is no longer relevant:
1. Create an `archive/` subdirectory if it doesn't exist
2. Move the file to the archive
3. Update any links to the archived content
4. Add a note explaining why it was archived

## Tips for Success

### Before You Start
- Review existing content to avoid duplication
- Check if a template exists for your content type
- Understand the purpose of the section you're contributing to

### While Writing
- Use the template as a guide, not a strict requirement
- Include practical examples
- Think about your audience
- Test any code or configurations

### After Submitting
- Respond to reviews promptly
- Be open to feedback
- Help maintain your content over time

## Questions?

If you have questions about contributing:
1. Check the main [README](./README.md)
2. Review existing content for examples
3. Open an issue for discussion
4. Reach out to the maintainers

## Resources

- [Markdown Guide](https://www.markdownguide.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
- [Writing Good Documentation](https://www.writethedocs.org/guide/)

---

Thank you for contributing to our AI Knowledgebase! Your contributions help the entire team work more effectively with AI tools.
