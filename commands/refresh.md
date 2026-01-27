---
description: Refresh ai-knowledgebase - pull latest and re-run setup to get new skills, commands, and agents
---

# Refresh AI Knowledgebase

Find the ai-knowledgebase repository, pull latest changes, and re-run setup.

## Steps

1. **Find ai-knowledgebase repository**

   Search in this order:
   - Current directory (if it IS ai-knowledgebase)
   - Parent directories up to 5 levels
   - Sibling directories (../ai-knowledgebase)
   - Common locations: ~/git/ai-knowledgebase, ~/Developer/ai-knowledgebase, ~/Projects/ai-knowledgebase, ~/code/ai-knowledgebase

   To detect ai-knowledgebase, look for: `skills/` directory AND `commands/` directory AND `AGENTS.md` file

2. **If not found:**
   ```
   Could not find ai-knowledgebase repository.
   
   You can install it with:
   curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
   ```
   Stop here.

3. **If found, pull latest changes:**
   ```bash
   cd <found-path>
   git pull
   ```

4. **Re-run setup:**
   ```bash
   ./tools/setup.sh
   ```

5. **Report result:**
   ```
   ✓ ai-knowledgebase refreshed at: <path>
   ✓ Setup complete
   ```

6. **Ask to close terminal:**
   
   Use the question tool to ask:
   ```
   Restart terminal to apply changes? (Y/n)
   ```
   
   - If user selects **Y** (or Yes): Run `kill -9 $PPID` to close the terminal
   - If user selects **n** (or No): Tell them to manually restart their terminal or run `source ~/.bashrc` / `source ~/.zshrc`

## Search Script

Use this bash to find the repository:

```bash
find_ai_knowledgebase() {
  local dir="$1"
  
  # Check if this IS ai-knowledgebase
  if [[ -d "$dir/skills" && -d "$dir/commands" && -f "$dir/AGENTS.md" ]]; then
    echo "$dir"
    return 0
  fi
  
  # Check parent directories (up to 5 levels)
  local current="$dir"
  for i in {1..5}; do
    current="$(dirname "$current")"
    if [[ -d "$current/skills" && -d "$current/commands" && -f "$current/AGENTS.md" ]]; then
      echo "$current"
      return 0
    fi
    # Also check if ai-knowledgebase is a sibling
    if [[ -d "$current/ai-knowledgebase/skills" && -d "$current/ai-knowledgebase/commands" && -f "$current/ai-knowledgebase/AGENTS.md" ]]; then
      echo "$current/ai-knowledgebase"
      return 0
    fi
  done
  
  # Check common locations
  for loc in ~/git/ai-knowledgebase ~/Developer/ai-knowledgebase ~/Projects/ai-knowledgebase ~/code/ai-knowledgebase ~/repos/ai-knowledgebase; do
    if [[ -d "$loc/skills" && -d "$loc/commands" && -f "$loc/AGENTS.md" ]]; then
      echo "$loc"
      return 0
    fi
  done
  
  return 1
}

# Usage:
KB_PATH=$(find_ai_knowledgebase "$(pwd)")
```

## Closing the Terminal

To close the terminal after refresh:
```bash
# This kills the parent process (the terminal/shell that spawned opencode)
kill -9 $PPID
```

Note: This may not work in all terminal environments, but works in most standard terminals.
