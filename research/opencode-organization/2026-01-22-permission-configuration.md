---
topic: Permission & Tool Configuration Patterns
date: 2026-01-22
project: opencode-organization
sources_count: 5
status: draft
tags: [permissions, tools, configuration, security]
---

# Permission & Tool Configuration Patterns

## Summary

OpenCode's permission system provides granular control over what actions agents can take, using a three-level approach: `allow`, `ask`, and `deny`. Permissions can be configured globally in `opencode.json`, overridden per-agent, and use glob patterns for fine-grained control over specific operations (like which bash commands require approval).

The built-in agents demonstrate three distinct permission profiles: **Build** (full access), **Plan** (ask-first for modifications), and **Explore** (read-only). These profiles serve as templates for custom agent configurations based on use case - research agents might need web access but not file editing, while documentation agents might need write access but not bash.

For team environments, skill permissions provide an additional layer of control, allowing organizations to whitelist approved skills while requiring approval for experimental ones. Combined with bash command patterns, this enables security-conscious workflows without sacrificing productivity.

## Key Findings

1. **Permission precedence**: Agent permissions override global config. Within a permission object, rules are evaluated in order with the **last matching rule winning** - put catch-all `*` first, specific rules after.

2. **Three permission levels**: `allow` (run without approval), `ask` (prompt user), `deny` (block entirely). When `deny` is set, the tool/action is hidden from the agent entirely.

3. **Built-in agents differ only in permissions**: Build has full access, Plan requires asking for modifications, Explore is read-only. Custom agents should follow similar profiles based on their purpose.

4. **Glob patterns for granular control**: Both bash commands and file paths support wildcards (`*` matches any characters, `?` matches single character). This enables patterns like `git *: allow` but `git push *: ask`.

5. **Skill permissions for team governance**: Pattern-based skill permissions (`internal-*: deny`) allow organizations to control which skills are available, with wildcards for prefixed groups.

6. **Task permissions control orchestration**: Primary agents can restrict which subagents they can invoke via `permission.task`, useful for building controlled orchestration patterns.

7. **`external_directory` and `doom_loop` safety guards**: These special permissions default to `ask` and prevent accidental operations outside the project or infinite loops.

## Permission Profiles

### Read-Only Profile (Explore-style)

Best for: Code exploration, answering questions, analysis tasks.

```json
{
  "tools": {
    "write": false,
    "edit": false,
    "bash": false,
    "patch": false
  },
  "permission": {
    "edit": "deny",
    "bash": "deny"
  }
}
```

### Planning Profile (Plan-style)

Best for: Architecture review, planning tasks, code review without changes.

```json
{
  "tools": {
    "write": true,
    "edit": true,
    "bash": true
  },
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "webfetch": "allow"
  }
}
```

### Full Access Profile (Build-style)

Best for: Implementation tasks, refactoring, feature development.

```json
{
  "tools": {
    "write": true,
    "edit": true,
    "bash": true
  },
  "permission": {
    "edit": "allow",
    "bash": "allow",
    "webfetch": "allow"
  }
}
```

### Research Profile (Custom)

Best for: Research agents that need web access and file creation but limited shell access.

```json
{
  "tools": {
    "write": true,
    "edit": true,
    "bash": false
  },
  "permission": {
    "edit": "allow",
    "webfetch": "allow"
  }
}
```

This matches your current `agents/research.md` configuration.

### Security Auditor Profile (Custom)

Best for: Security review agents that can analyze but not modify.

```json
{
  "tools": {
    "write": false,
    "edit": false
  },
  "permission": {
    "bash": {
      "*": "deny",
      "grep *": "allow",
      "find *": "allow",
      "git log *": "allow",
      "git diff *": "allow"
    }
  }
}
```

## Bash Permission Patterns

| Pattern | Use Case | Behavior |
|---------|----------|----------|
| `"*": "ask"` | Default catch-all | All commands require approval |
| `"git *": "allow"` | Git operations | Allow all git commands without asking |
| `"git push *": "ask"` | Push protection | Allow git, but confirm pushes |
| `"git push --force*": "deny"` | Force push protection | Block force pushes entirely |
| `"npm *": "allow"` | Package management | Allow npm commands |
| `"rm *": "deny"` | Delete protection | Block all remove commands |
| `"grep *": "allow"` | Search operations | Allow grep without asking |
| `"docker *": "ask"` | Container operations | Require approval for docker |

### Example: Development-Safe Bash Config

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git status*": "allow",
      "git diff*": "allow",
      "git log*": "allow",
      "git branch*": "allow",
      "git checkout*": "allow",
      "git add*": "allow",
      "git commit*": "ask",
      "git push*": "ask",
      "git push --force*": "deny",
      "npm run*": "allow",
      "npm test*": "allow",
      "npm install*": "ask",
      "grep *": "allow",
      "ls *": "allow",
      "cat *": "allow"
    }
  }
}
```

## Skill Permission Patterns

For team environments, skill permissions control which skills agents can load.

| Pattern | Use Case | Example |
|---------|----------|---------|
| `"*": "allow"` | Trust all skills | Open development |
| `"internal-*": "deny"` | Block internal skills | Hide sensitive workflows |
| `"experimental-*": "ask"` | Approve experimental | New skills need confirmation |
| `"pr-review": "allow"` | Whitelist specific | Only allow vetted skills |

### Team Governance Configuration

```json
{
  "permission": {
    "skill": {
      "*": "ask",
      "research": "allow",
      "deep-research": "allow",
      "playwright-test": "allow",
      "vue-component": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

### Per-Agent Skill Override

```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

## Task Permission Patterns

Control which subagents a primary agent can invoke:

```json
{
  "agent": {
    "orchestrator": {
      "permission": {
        "task": {
          "*": "deny",
          "explore": "allow",
          "general": "allow",
          "code-reviewer": "ask"
        }
      }
    }
  }
}
```

When a subagent is denied, it's removed from the Task tool description entirely - the model won't even try to use it.

## Current Setup Analysis

### Your Configuration

Your `.opencode/config.json` contains:
- MCP servers: notion, google-ai-search, penpot, mongodb
- No explicit permission configuration

Your `agents/research.md` defines:
- `tools: { write: true, edit: true, bash: false }`
- No explicit permission blocks

### Observations

1. **No global permission config**: Your setup relies on defaults (mostly `allow`). Consider adding explicit bash patterns if agents are used for sensitive operations.

2. **Research agent appropriately restricted**: Disabling bash for research is correct - web research shouldn't need shell access.

3. **MCP servers unrestricted**: Tools from MCP servers (like `notion_search`, `google_ai_search_plus`) use default permissions. Consider `"mymcp_*": "ask"` patterns if needed.

4. **No skill permissions**: All 25+ skills are available to all agents. Consider whether some skills should be restricted by agent type.

## Recommendations

### 1. Add Global Permission Baseline

```json
{
  "permission": {
    "*": "allow",
    "external_directory": "ask",
    "doom_loop": "ask",
    "bash": {
      "*": "ask",
      "git status*": "allow",
      "git diff*": "allow",
      "git log*": "allow",
      "grep *": "allow",
      "ls *": "allow"
    }
  }
}
```

### 2. Create Specialized Agents with Distinct Profiles

Consider creating these agents:

| Agent | Mode | Profile | Use Case |
|-------|------|---------|----------|
| `build` | primary | Full access | Implementation work |
| `plan` | primary | Ask-first | Planning, review |
| `research` | primary | Web + write, no bash | Research tasks |
| `explore` | subagent | Read-only | Codebase exploration |
| `security-review` | subagent | Restricted bash | Security audits |

### 3. Organize Skills by Sensitivity

Consider prefixing skills:
- `core-*` - Always available
- `team-*` - Team-specific, approved
- `experimental-*` - Require approval
- `internal-*` - Hidden from subagents

### 4. Document Permission Rationale

Add a comment or separate doc explaining why permissions are configured as they are - helpful for team onboarding.

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [OpenCode Agents Docs](https://opencode.ai/docs/agents) | Official | Agent configuration, tools/permissions, built-in agent profiles |
| [OpenCode Permissions Docs](https://opencode.ai/docs/permissions) | Official | Permission levels, granular rules, glob patterns, agent overrides |
| [OpenCode Tools Docs](https://opencode.ai/docs/tools) | Official | Built-in tools list, permission configuration per tool |
| [OpenCode Skills Docs](https://opencode.ai/docs/skills) | Official | Skill permissions, pattern-based access control |
| Your agents/research.md | Internal | Example of tools configuration in practice |

## Questions for Further Research

- [ ] How do MCP server tool permissions interact with built-in tool permissions?
- [ ] Can permission patterns use negation (e.g., `!*.env` to allow)?
- [ ] How are permission conflicts resolved when multiple patterns match?
- [ ] Do skill permissions affect which skills appear in autocomplete vs just loading?
