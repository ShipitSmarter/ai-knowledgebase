# Safety Permissions

OpenCode is configured with safety permissions to prevent accidental dangerous operations.

## What's Protected

### Kubernetes (Blocked)

All `kubectl` commands are **completely blocked**:

```bash
# ❌ BLOCKED - Will show error
kubectl get pods
kubectl apply -f deployment.yaml
kubectl delete namespace production
```

**Why?** Prevents accidental changes to production clusters. Use dedicated tools or manual kubectl commands outside of AI assistants.

### Git Operations (Ask First)

Git write operations require **confirmation** before running:

```bash
# ⚠️ ASKS - Will prompt for approval
git commit -m "update"
git push
git pull
git rebase main
git merge feature-branch
git reset --hard
git checkout -b new-branch
git stash
```

**Why?** Git operations affect your repository state and can be destructive. AI confirms intent before executing.

### Safe Git Reads (Allowed)

Git read operations run **without prompting**:

```bash
# ✅ ALLOWED - Runs immediately
git status
git log
git diff
git show
git ls-files
git remote -v
```

**Why?** These commands are read-only and help AI understand repository state.

### Dangerous File Operations (Ask First)

```bash
# ⚠️ ASKS - Will prompt for approval
rm -rf directory/
sudo apt install package
```

**Why?** Destructive operations or privilege escalation require confirmation.

### Sensitive Files (Blocked)

Reading environment files with secrets is **blocked**:

```bash
# ❌ BLOCKED
read .env
read .env.production

# ✅ ALLOWED
read .env.example
```

**Why?** Prevents accidentally exposing secrets to AI models.

## How It Works

### Configuration File

Safety rules are stored in `~/.config/opencode/opencode.json`:

```json
{
  "permission": {
    "bash": {
      "*": "allow",
      "kubectl*": "deny",
      "git commit*": "ask",
      "git status*": "allow"
    }
  }
}
```

### Rule Syntax

- `"command*": "allow"` - Runs without prompting
- `"command*": "ask"` - Prompts for confirmation
- `"command*": "deny"` - Completely blocked

### Pattern Matching

Patterns use glob-style wildcards:

- `"kubectl*"` - Matches `kubectl`, `kubectl get`, `kubectl apply`, etc.
- `"git commit*"` - Matches `git commit`, `git commit -m "msg"`, etc.
- `"*.env"` - Matches `.env`, `production.env`, etc.

More specific patterns override general ones:

```json
{
  "git *": "ask",           // Ask for all git commands
  "git status*": "allow"    // But allow git status without asking
}
```

## Setup Process

The setup script (`tools/setup.sh`) automatically manages the safety configuration:

### 1. **First Time Setup**

When you run setup for the first time:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

**Step 3.5: Safety Permissions**
- Creates `~/.config/opencode/opencode.json` with recommended defaults
- All safety rules applied automatically
- No user input needed

### 2. **Existing Config Without Permissions**

If you already have a config file but it lacks safety permissions:

```
⚠️ Existing config found without safety permissions

Replace with recommended safety config? (Y/n)
```

- **Y (default)**: Backs up your old config to `opencode.json.backup` and applies safety defaults
- **n**: Keeps your config unchanged (you can manually add permissions from `opencode/opencode.json.example`)

### 3. **Existing Config With Different Permissions**

If your config has permissions but they differ from recommended defaults:

```
⚠️ Existing config differs from recommended defaults

Your config has custom settings or outdated permissions

Replace with latest recommended config? (y/N)
```

- **y**: Backs up your old config to `opencode.json.backup` and updates to latest defaults
- **N (default)**: Keeps your custom config (compare with `opencode/opencode.json.example` to see what changed)

### 4. **Config Already Up to Date**

If your config matches the recommended defaults:

```
✓ Safety permissions up to date
```

No action needed.

### Comparison Logic

The script compares configs intelligently:

1. **Uses `jq` if available** - Normalizes JSON (removes whitespace, sorts keys)
2. **Fallback without `jq`** - Removes all whitespace and compares
3. **Detects any differences** - Extra fields, missing rules, different values

This ensures your custom MCP settings, instructions, or other config sections are preserved if you choose to keep your existing config.

## Customizing Permissions

### For This Repository Only

Create `.opencode/config.json` in your project root (not in home directory):

```json
{
  "permission": {
    "bash": {
      "npm publish*": "ask"
    }
  }
}
```

This merges with global settings.

### For Specific Agents

Agents can have stricter rules in their definition files (`agents/<name>.md`):

```markdown
---
description: Research agent without bash access
mode: subagent
permission:
  bash: deny
---

You are a research specialist focused on web research...
```

### Override for Your Machine

Edit `~/.config/opencode/opencode.json` to adjust rules:

```json
{
  "permission": {
    "bash": {
      "docker*": "ask"  // Add Docker confirmation
    }
  }
}
```

## Testing Permissions

After setup, verify the safety rules work:

```bash
# Should be BLOCKED
opencode run "kubectl get pods"

# Should PROMPT for approval
opencode run "git commit -m 'test'"

# Should run WITHOUT prompting
opencode run "git status"
```

## Example Scenarios

### Scenario 1: AI Wants to Commit Code

```
User: "Fix the bug and commit the changes"

AI: "I found the issue in src/utils/parser.ts. I'll fix it now."
[AI fixes the code]

AI: "Now I'll commit the changes."
[OpenCode prompts: "Allow git commit -m 'Fix parser bug'?"]
  → Once
  → Always for this session
  → Reject

User: [Selects "Once"]

AI: "Committed successfully."
```

### Scenario 2: AI Tries Kubectl

```
User: "Check if the pods are running"

AI: "I'll check the Kubernetes pods."
[OpenCode blocks: "kubectl get pods is not allowed"]

AI: "I don't have permission to run kubectl. Please run this manually:
  kubectl get pods"
```

### Scenario 3: Safe Git Operations

```
User: "What changed since last commit?"

AI: "Let me check git diff."
[Runs immediately without prompting]

AI: "Here are the changes:
  - Modified src/components/Header.vue
  - Added new prop 'showLogo'
  ..."
```

## Security Considerations

### What This Protects Against

✅ Accidental destructive commands  
✅ Unintended cluster modifications  
✅ Commits without review  
✅ Exposure of secrets in .env files

### What This Does NOT Protect Against

❌ Malicious prompt injection (always review AI suggestions)  
❌ Logic bugs in code AI writes  
❌ Copying sensitive data to external systems

**Always review AI-generated code before approving operations.**

## Troubleshooting

### "Permission denied" for safe commands

Check your config file:

```bash
cat ~/.config/opencode/opencode.json
```

Ensure safe commands like `git status` are marked `"allow"`.

### Permissions not working

1. Verify config exists:
   ```bash
   ls -la ~/.config/opencode/opencode.json
   ```

2. Check JSON syntax is valid:
   ```bash
   cat ~/.config/opencode/opencode.json | jq .
   ```

3. Restart OpenCode session

### Want to disable safety for one session

Set environment variable:

```bash
OPENCODE_UNSAFE=1 opencode
```

⚠️ **Warning:** Only use this if you understand the risks.

---

## Reference: Default Safety Rules

```json
{
  "permission": {
    "bash": {
      "*": "allow",
      
      "kubectl*": "deny",
      "kubectl *": "deny",
      
      "git commit*": "ask",
      "git push*": "ask",
      "git pull*": "ask",
      "git rebase*": "ask",
      "git merge*": "ask",
      "git reset*": "ask",
      "git checkout*": "ask",
      "git switch*": "ask",
      "git fetch*": "ask",
      "git cherry-pick*": "ask",
      "git stash*": "ask",
      "git tag*": "ask",
      "git branch*": "ask",
      
      "git status*": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "git show*": "allow",
      "git ls-files*": "allow",
      "git remote*": "allow",
      "git config --get*": "allow",
      "git rev-parse*": "allow",
      
      "rm -rf*": "ask",
      "sudo*": "ask"
    },
    
    "read": {
      "*": "allow",
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.example": "allow"
    }
  }
}
```

See `opencode/opencode.json.example` for the full reference configuration.
