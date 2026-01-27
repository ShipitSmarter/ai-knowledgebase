---
description: Update ai-knowledgebase and re-run setup to get latest skills, commands, and agents
---

# Update AI Knowledgebase

Find the ai-knowledgebase repository and re-run setup to get the latest changes.

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
   ✓ ai-knowledgebase updated at: <path>
   ✓ Setup complete - restart your terminal or run 'source ~/.bashrc' to apply changes
   ```

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

## Notes

- This command is useful after someone mentions "ai-knowledgebase has been updated"
- Always pull before running setup to get latest changes
- Setup script is idempotent - safe to run multiple times
