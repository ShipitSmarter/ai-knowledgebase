---
topic: AI Commit Attribution Implementation
date: 2026-01-26
project: ai-commit-attribution
sources_count: 4
status: draft
tags: [git, ai-attribution, hooks, automation]
---

# AI Commit Attribution Implementation

A complete system for tracking AI involvement in git commits using trailers, environment variables, hooks, and notes.

## Summary

This document provides a working implementation for transparent AI attribution in git commits. The system uses environment variables set by AI tools, git hooks to automatically add trailers, git notes for extended metadata, and shell integration to ensure variables are cleared after each commit (defaulting to human-authored).

**Key design decision**: The session ID persists across multiple commits within the same AI session. Only the per-commit variables (like `AI_LINES_ADDED`) are cleared after each commit. This allows you to trace multiple commits back to a single AI working session.

## Key Components

1. **Environment Variables** - Set by AI tools during sessions
2. **prepare-commit-msg Hook** - Adds trailers based on env vars
3. **post-commit Hook** - Adds git notes and clears env vars
4. **Shell Integration** - Ensures cleanup even if hooks fail
5. **Contribution Tracking** - Approaches for measuring AI vs human contribution

---

## 1. Environment Variables

Define these variables when AI is involved:

| Variable | Purpose | Example Values | Cleared After Commit? |
|----------|---------|----------------|----------------------|
| `AI_ASSISTED` | Flag that AI was involved | `1` or `true` | No (session-level) |
| `AI_MODEL` | Which AI model | `claude-opus-4.5`, `gpt-4`, `copilot` | No (session-level) |
| `AI_TOOL` | Which tool/interface | `opencode`, `cursor`, `copilot` | No (session-level) |
| `AI_CONTRIBUTION` | Level of involvement | `full`, `partial`, `review-only` | No (session-level) |
| `AI_SESSION_ID` | Session identifier | UUID or timestamp | No (session-level) |
| `AI_LINES_ADDED` | Lines AI wrote (for percentage) | `150` | **Yes** (per-commit) |
| `AI_LINES_TOTAL` | Total lines in commit | `200` | **Yes** (per-commit) |
| `AI_FILES_TOUCHED` | Files modified by AI | `src/api.ts,src/utils.ts` | **Yes** (per-commit) |

**Session vs Commit variables**: Session-level variables persist until you explicitly end the session with `ai-session-end`. This means multiple commits in the same AI session share the same session ID, making it easy to audit "all commits from this AI conversation".

### Setting Variables (AI Tool Integration)

AI tools should set these when they write code. Example for OpenCode plugin:

```typescript
// In AI tool when writing code
process.env.AI_ASSISTED = '1';
process.env.AI_MODEL = 'claude-opus-4.5';
process.env.AI_TOOL = 'opencode';
process.env.AI_CONTRIBUTION = 'partial';
process.env.AI_SESSION_ID = crypto.randomUUID();
```

### Manual Setting (Shell)

For manual sessions:

```bash
# Start AI-assisted work
export AI_ASSISTED=1
export AI_MODEL="claude-opus-4.5"
export AI_TOOL="opencode"
export AI_CONTRIBUTION="partial"
export AI_SESSION_ID=$(uuidgen)

# ... do work with AI ...

# Commit (hooks will handle attribution and cleanup)
git commit -m "Add feature"
```

---

## 2. Git Hooks

### prepare-commit-msg Hook

This hook adds trailers to the commit message based on environment variables.

**File: `.git/hooks/prepare-commit-msg`**

```bash
#!/bin/bash
#
# prepare-commit-msg hook for AI attribution
# Adds trailers based on AI_* environment variables
#

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2
SHA1=$3

# Skip if this is a merge, squash, or amend
if [ "$COMMIT_SOURCE" = "merge" ] || [ "$COMMIT_SOURCE" = "squash" ]; then
    exit 0
fi

# Only proceed if AI_ASSISTED is set
if [ -z "$AI_ASSISTED" ] || [ "$AI_ASSISTED" != "1" ]; then
    exit 0
fi

# Check if trailers already exist (avoid duplicates on amend)
if grep -q "^AI-assisted-by:" "$COMMIT_MSG_FILE"; then
    exit 0
fi

# Build the trailer block
TRAILERS=""

# AI Model/Tool attribution
if [ -n "$AI_MODEL" ]; then
    if [ -n "$AI_TOOL" ]; then
        TRAILERS="${TRAILERS}AI-assisted-by: ${AI_MODEL} via ${AI_TOOL}\n"
    else
        TRAILERS="${TRAILERS}AI-assisted-by: ${AI_MODEL}\n"
    fi
elif [ -n "$AI_TOOL" ]; then
    TRAILERS="${TRAILERS}AI-assisted-by: ${AI_TOOL}\n"
else
    TRAILERS="${TRAILERS}AI-assisted-by: AI assistant\n"
fi

# Contribution level
if [ -n "$AI_CONTRIBUTION" ]; then
    TRAILERS="${TRAILERS}AI-contribution: ${AI_CONTRIBUTION}\n"
fi

# Calculate percentage if line counts available
if [ -n "$AI_LINES_ADDED" ] && [ -n "$AI_LINES_TOTAL" ] && [ "$AI_LINES_TOTAL" -gt 0 ]; then
    PERCENTAGE=$((AI_LINES_ADDED * 100 / AI_LINES_TOTAL))
    TRAILERS="${TRAILERS}AI-percentage: ${PERCENTAGE}%\n"
fi

# Session ID (useful for auditing)
if [ -n "$AI_SESSION_ID" ]; then
    TRAILERS="${TRAILERS}AI-session: ${AI_SESSION_ID}\n"
fi

# Append trailers to commit message
# Ensure there's a blank line before trailers
echo "" >> "$COMMIT_MSG_FILE"
echo -e "$TRAILERS" >> "$COMMIT_MSG_FILE"
```

### post-commit Hook

This hook adds git notes with detailed metadata. Note: it does NOT clear session variables - that's handled by the shell integration, which only clears per-commit vars.

**File: `.git/hooks/post-commit`**

```bash
#!/bin/bash
#
# post-commit hook for AI attribution
# - Adds detailed git notes with session and commit metadata
# - Does NOT clear variables (shell integration handles that)
#

# Only proceed if AI was involved
if [ -z "$AI_ASSISTED" ] || [ "$AI_ASSISTED" != "1" ]; then
    exit 0
fi

# Get the commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Build detailed note (can include more info than trailers)
NOTE="AI Attribution Details
=====================
Model: ${AI_MODEL:-unknown}
Tool: ${AI_TOOL:-unknown}
Contribution: ${AI_CONTRIBUTION:-unknown}
Session ID: ${AI_SESSION_ID:-none}
Commit Time: $(date -Iseconds)"

# Add line statistics if available
if [ -n "$AI_LINES_ADDED" ]; then
    NOTE="${NOTE}
Lines Added by AI: ${AI_LINES_ADDED}"
fi
if [ -n "$AI_LINES_TOTAL" ]; then
    NOTE="${NOTE}
Total Lines Changed: ${AI_LINES_TOTAL}"
fi
if [ -n "$AI_LINES_ADDED" ] && [ -n "$AI_LINES_TOTAL" ] && [ "$AI_LINES_TOTAL" -gt 0 ]; then
    PERCENTAGE=$((AI_LINES_ADDED * 100 / AI_LINES_TOTAL))
    NOTE="${NOTE}
AI Contribution: ${PERCENTAGE}%"
fi

# Add files touched if available
if [ -n "$AI_FILES_TOUCHED" ]; then
    NOTE="${NOTE}

Files Modified by AI:
${AI_FILES_TOUCHED}"
fi

# Add any additional context
if [ -n "$AI_CONTEXT" ]; then
    NOTE="${NOTE}

Context:
${AI_CONTEXT}"
fi

# Create the note
echo "$NOTE" | git notes add -f -F - "$COMMIT_HASH" 2>/dev/null || true

echo "AI attribution added to commit ${COMMIT_HASH:0:7}"
```

### Install Script

**File: `install-ai-hooks.sh`**

```bash
#!/bin/bash
#
# Install AI attribution hooks to a git repository
#

HOOKS_DIR=".git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
    echo "Error: Not in a git repository root"
    exit 1
fi

# Create prepare-commit-msg hook
cat > "$HOOKS_DIR/prepare-commit-msg" << 'HOOK_END'
#!/bin/bash
# [Contents of prepare-commit-msg hook from above]
HOOK_END

# Create post-commit hook  
cat > "$HOOKS_DIR/post-commit" << 'HOOK_END'
#!/bin/bash
# [Contents of post-commit hook from above]
HOOK_END

chmod +x "$HOOKS_DIR/prepare-commit-msg"
chmod +x "$HOOKS_DIR/post-commit"

echo "AI attribution hooks installed successfully!"
echo ""
echo "Usage:"
echo "  export AI_ASSISTED=1 AI_MODEL='claude-opus-4.5' AI_TOOL='opencode'"
echo "  git commit -m 'Your message'"
echo ""
echo "Don't forget to add shell integration for auto-cleanup."
```

---

## 3. Shell Integration (Auto-Cleanup)

The hooks run in subprocesses, so they can't directly unset variables in your shell. Add this to your shell config:

### Bash (~/.bashrc)

```bash
# AI Commit Attribution - Auto-cleanup
# Wraps git to clear per-commit AI vars after commit
# Session vars (AI_ASSISTED, AI_MODEL, AI_TOOL, AI_SESSION_ID) persist until ai-session-end

# Clear only per-commit variables (called after each commit)
_ai_commit_var_cleanup() {
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

# Clear all AI variables (called when ending session)
_ai_session_cleanup() {
    unset AI_ASSISTED AI_MODEL AI_TOOL AI_CONTRIBUTION AI_SESSION_ID
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

# Override git command to cleanup per-commit vars after commit
git() {
    command git "$@"
    local exit_code=$?
    
    # If this was a successful commit and AI session is active, clear per-commit vars
    if [ "$1" = "commit" ] && [ $exit_code -eq 0 ]; then
        if [ -n "$AI_ASSISTED" ]; then
            _ai_commit_var_cleanup
            echo "AI commit recorded (session $AI_SESSION_ID still active)"
        fi
    fi
    
    return $exit_code
}

# Helper function to start AI session
ai-session-start() {
    export AI_ASSISTED=1
    export AI_MODEL="${1:-unknown}"
    export AI_TOOL="${2:-cli}"
    export AI_CONTRIBUTION="${3:-partial}"
    # Session ID: timestamp-pid for uniqueness, or use provided ID
    export AI_SESSION_ID="${4:-$(date +%Y%m%d-%H%M%S)-$$}"
    echo "AI session started:"
    echo "  Model: $AI_MODEL"
    echo "  Tool: $AI_TOOL"
    echo "  Session ID: $AI_SESSION_ID"
    echo ""
    echo "All commits will be attributed to this session until you run: ai-session-end"
}

# End session - clears all AI variables
ai-session-end() {
    if [ -n "$AI_SESSION_ID" ]; then
        echo "AI session ended: $AI_SESSION_ID"
    fi
    _ai_session_cleanup
    echo "Next commit will be human-attributed"
}

# Show current AI session status
ai-session-status() {
    if [ -n "$AI_ASSISTED" ]; then
        echo "AI Session Active:"
        echo "  Model: ${AI_MODEL:-not set}"
        echo "  Tool: ${AI_TOOL:-not set}"
        echo "  Contribution: ${AI_CONTRIBUTION:-not set}"
        echo "  Session ID: ${AI_SESSION_ID:-not set}"
        echo ""
        echo "Per-commit stats (will be cleared after commit):"
        echo "  Lines Added: ${AI_LINES_ADDED:-not tracked}"
        echo "  Files Touched: ${AI_FILES_TOUCHED:-not tracked}"
    else
        echo "No AI session active (commits will be human-attributed)"
        echo ""
        echo "Start a session with: ai-session-start <model> <tool>"
        echo "Example: ai-session-start claude-opus-4.5 opencode"
    fi
}
```

### Zsh (~/.zshrc)

```zsh
# AI Commit Attribution - Auto-cleanup (Zsh version)
# Session vars persist until ai-session-end; per-commit vars cleared after each commit

# Clear only per-commit variables
_ai_commit_var_cleanup() {
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

# Clear all AI variables
_ai_session_cleanup() {
    unset AI_ASSISTED AI_MODEL AI_TOOL AI_CONTRIBUTION AI_SESSION_ID
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

# Wrap git command
git() {
    command git "$@"
    local exit_code=$?
    
    if [[ "$1" == "commit" ]] && [[ $exit_code -eq 0 ]] && [[ -n "$AI_ASSISTED" ]]; then
        _ai_commit_var_cleanup
        echo "AI commit recorded (session $AI_SESSION_ID still active)"
    fi
    
    return $exit_code
}

# Helper functions
ai-session-start() {
    export AI_ASSISTED=1
    export AI_MODEL="${1:-unknown}"
    export AI_TOOL="${2:-cli}"
    export AI_CONTRIBUTION="${3:-partial}"
    export AI_SESSION_ID="${4:-$(date +%Y%m%d-%H%M%S)-$$}"
    echo "AI session started:"
    echo "  Model: $AI_MODEL"
    echo "  Tool: $AI_TOOL"
    echo "  Session ID: $AI_SESSION_ID"
    echo ""
    echo "All commits will be attributed to this session until you run: ai-session-end"
}

ai-session-end() {
    if [[ -n "$AI_SESSION_ID" ]]; then
        echo "AI session ended: $AI_SESSION_ID"
    fi
    _ai_session_cleanup
    echo "Next commit will be human-attributed"
}

ai-session-status() {
    if [[ -n "$AI_ASSISTED" ]]; then
        echo "AI Session Active:"
        echo "  Model: ${AI_MODEL:-not set}"
        echo "  Tool: ${AI_TOOL:-not set}"
        echo "  Contribution: ${AI_CONTRIBUTION:-not set}"
        echo "  Session ID: ${AI_SESSION_ID:-not set}"
        echo ""
        echo "Per-commit stats (will be cleared after commit):"
        echo "  Lines Added: ${AI_LINES_ADDED:-not tracked}"
        echo "  Files Touched: ${AI_FILES_TOUCHED:-not tracked}"
    else
        echo "No AI session active (commits will be human-attributed)"
        echo ""
        echo "Start a session with: ai-session-start <model> <tool>"
        echo "Example: ai-session-start claude-opus-4.5 opencode"
    fi
}
```

---

## 4. Contribution Percentage Tracking

This is the tricky part. There are several approaches:

### Approach A: Manual Estimation

The simplest - human estimates the AI contribution:

```bash
export AI_CONTRIBUTION="partial"  # full, partial, review-only
```

### Approach B: Line-Based Tracking

Track lines written by AI vs human. Requires AI tool integration:

```bash
# AI tool sets these after writing code
export AI_LINES_ADDED=150
export AI_LINES_TOTAL=200
# Hook calculates: 150/200 = 75%
```

**How AI tools can track this:**

1. **Before AI writes**: Snapshot the file state
2. **After AI writes**: Diff to count added/modified lines
3. **Set environment variables** with the counts

### Approach C: Git Diff Analysis

Analyze the staged diff before commit:

```bash
# Add to prepare-commit-msg hook:

# Get total lines being committed
TOTAL_LINES=$(git diff --cached --numstat | awk '{sum += $1 + $2} END {print sum}')
export AI_LINES_TOTAL=$TOTAL_LINES

# AI_LINES_ADDED must still come from the AI tool
# It knows what it wrote; git can't distinguish
```

### Approach D: File-Level Attribution

Track which files were AI-touched:

```bash
# AI tool maintains a list of files it modified
export AI_FILES_TOUCHED="src/api.ts,src/utils.ts"

# Hook can then calculate:
# - Total files in commit
# - Percentage that were AI-touched
```

### Approach E: Semantic Analysis (Advanced)

Use an LLM to analyze the diff and estimate AI contribution based on style, patterns, etc. This is complex and probably overkill for most use cases.

### Recommended: Hybrid Approach

```bash
# Level 1: Always set (manual)
export AI_CONTRIBUTION="partial"  # human judgment

# Level 2: If tool supports it (automatic)
export AI_LINES_ADDED=150
export AI_LINES_TOTAL=200

# Level 3: File tracking (automatic)
export AI_FILES_TOUCHED="file1.ts,file2.ts"
```

The hooks use whatever is available, with graceful fallbacks.

---

## 5. Git Notes Integration

Git notes store extended metadata separately from commit messages.

### View Notes

```bash
# Show notes for a commit
git notes show HEAD

# Show all commits with their notes
git log --show-notes
```

### Push/Pull Notes

Notes aren't pushed by default:

```bash
# Push notes
git push origin refs/notes/commits

# Fetch notes
git fetch origin refs/notes/commits:refs/notes/origin/commits

# Configure to always push/fetch notes
git config --add remote.origin.push refs/notes/commits
git config --add remote.origin.fetch refs/notes/commits:refs/notes/origin/commits
```

### Query AI-Attributed Commits

```bash
# Find all commits with AI notes
git log --all --notes --grep="AI Attribution" --format="%H %s"

# Custom script to list AI contributions
git log --format="%H" | while read hash; do
    if git notes show "$hash" 2>/dev/null | grep -q "AI Attribution"; then
        echo "$hash: $(git log -1 --format='%s' $hash)"
    fi
done
```

---

## 6. Complete Workflow Example

```bash
# 1. Start AI session (or AI tool does this automatically)
ai-session-start "claude-opus-4.5" "opencode" "partial"
# Output:
# AI session started:
#   Model: claude-opus-4.5
#   Tool: opencode
#   Session ID: 20260126-103000-12345
#
# All commits will be attributed to this session until you run: ai-session-end

# 2. Work with AI - it modifies files...
#    AI tool updates: AI_LINES_ADDED, AI_FILES_TOUCHED, etc.

# 3. Stage and commit first feature
git add .
git commit -m "Add user authentication feature"
# Output:
# AI attribution added to commit abc123
# AI commit recorded (session 20260126-103000-12345 still active)

# 4. Continue working with AI on another feature...

# 5. Second commit - SAME session ID!
git add .
git commit -m "Add password reset flow"
# Output:
# AI attribution added to commit def456
# AI commit recorded (session 20260126-103000-12345 still active)

# 6. Verify both commits share the session
git log -2 --format="%h %s" | while read hash msg; do
    echo "$hash: $msg"
done
# Shows:
#   def456: Add password reset flow
#     AI-session: 20260126-103000-12345
#   abc123: Add user authentication feature  
#     AI-session: 20260126-103000-12345

# 7. End the AI session when done
ai-session-end
# Output:
# AI session ended: 20260126-103000-12345
# Next commit will be human-attributed

# 8. Next commit is clean (no AI attribution)
git commit -m "Fix typo"  # No AI trailers added
```

---

## 7. OpenCode Plugin Integration

For OpenCode specifically, we created a plugin that automatically manages AI attribution when files are modified. The plugin is installed automatically via `setup.sh`.

**File: `plugins/ai-attribution.ts`**

```typescript
/**
 * AI Attribution Plugin for OpenCode
 * 
 * Automatically sets environment variables for AI commit attribution when
 * OpenCode modifies files. Works with the git hooks installed by setup.sh.
 */

import type { Plugin } from "@opencode-ai/plugin"

// Track files modified in this session
let filesModified: Set<string> = new Set()
let sessionStartTime: string | null = null

export const AIAttributionPlugin: Plugin = async ({ client }) => {
  
  // Helper to set environment variable
  const setEnv = (key: string, value: string) => {
    process.env[key] = value
  }
  
  // Initialize session tracking (first file modification starts the session)
  const initSession = async (sessionId: string) => {
    if (!sessionStartTime) {
      // Format: YYYYMMDD-HHMMSS-sessionId (last 8 chars)
      const now = new Date()
      const datePart = now.toISOString().slice(0, 10).replace(/-/g, '')
      const timePart = now.toTimeString().slice(0, 8).replace(/:/g, '')
      const sessionPart = sessionId.slice(-8)
      sessionStartTime = `${datePart}-${timePart}-${sessionPart}`
      
      setEnv('AI_ASSISTED', '1')
      setEnv('AI_TOOL', 'opencode')
      setEnv('AI_SESSION_ID', sessionStartTime)
      setEnv('AI_CONTRIBUTION', 'partial')
      
      await client.app.log({
        service: 'ai-attribution',
        level: 'info',
        message: `AI attribution session started: ${sessionStartTime}`,
      })
    }
  }
  
  // Update files touched
  const trackFile = (filePath: string) => {
    filesModified.add(filePath)
    setEnv('AI_FILES_TOUCHED', Array.from(filesModified).join(','))
  }
  
  return {
    // Handle session lifecycle and message events
    event: async ({ event }) => {
      if (event.type === 'session.created') {
        // Reset tracking for new session
        filesModified = new Set()
        sessionStartTime = null
      }
      
      if (event.type === 'session.deleted') {
        // Clean up when session ends
        filesModified = new Set()
        sessionStartTime = null
      }
      
      // Track model being used
      if (event.type === 'message.updated') {
        const message = (event as { type: string; message?: { model?: string } }).message
        if (message?.model) {
          const modelName = message.model.split('/').pop() || message.model
          setEnv('AI_MODEL', modelName)
        }
      }
    },
    
    // Track file modifications via edit/write tools
    'tool.execute.after': async (input, output) => {
      if (input.tool === 'edit' || input.tool === 'write') {
        const filePath = input.args?.filePath || input.args?.path
        if (filePath && !output.error) {
          // Initialize session on first file modification
          await initSession(input.sessionID || 'unknown')
          trackFile(filePath)
          
          await client.app.log({
            service: 'ai-attribution',
            level: 'debug',
            message: `Tracked file modification: ${filePath}`,
          })
        }
      }
    },
  }
}

export default AIAttributionPlugin
```

### How It Works

1. **On first file edit**: Creates a session ID and sets `AI_ASSISTED=1`
2. **On each edit/write**: Tracks the file path in `AI_FILES_TOUCHED`
3. **On message updates**: Captures the model name in `AI_MODEL`
4. **On session end**: Resets tracking (env vars persist for shell integration to clean up)

### What the Plugin Sets

| Variable | When Set | Value |
|----------|----------|-------|
| `AI_ASSISTED` | First file modification | `1` |
| `AI_TOOL` | First file modification | `opencode` |
| `AI_SESSION_ID` | First file modification | `YYYYMMDD-HHMMSS-<session>` |
| `AI_CONTRIBUTION` | First file modification | `partial` |
| `AI_MODEL` | When message is processed | e.g., `claude-opus-4.5` |
| `AI_FILES_TOUCHED` | Each file modification | Comma-separated paths |

### Manual vs Automatic

- **With plugin (OpenCode)**: Variables are set automatically when AI edits files
- **Without plugin (CLI)**: Use `ai-session-start` to set variables manually

The git hooks work with either approach - they just read the environment variables.

---

## 8. Tying Session IDs to Actual Sessions

The session ID format `YYYYMMDD-HHMMSS-PID` (e.g., `20260126-103000-12345`) is designed to be:
- **Unique**: Timestamp + process ID ensures no collisions
- **Sortable**: Date prefix allows chronological ordering
- **Traceable**: Can correlate with OpenCode session logs by timestamp

### Querying Commits by Session

```bash
# Find all commits from a specific AI session
git log --all --grep="AI-session: 20260126-103000-12345"

# List all unique AI sessions in the repo
git log --all --format="%b" | grep "^AI-session:" | sort -u

# Count commits per AI session
git log --all --format="%b" | grep "^AI-session:" | sort | uniq -c | sort -rn
```

### Correlating with OpenCode

If using OpenCode, sessions are logged to `~/.opencode/sessions/`. The timestamp in the session ID can help locate the corresponding conversation:

```bash
# Session ID: 20260126-103000-12345
# Look for OpenCode sessions around that time
ls -la ~/.opencode/sessions/ | grep "2026-01-26"
```

### Future: Session Log Files

For richer session tracking, AI tools could create session log files:

```bash
# AI tool creates: ~/.ai-sessions/<session-id>.json
{
  "session_id": "20260126-103000-12345",
  "started_at": "2026-01-26T10:30:00Z",
  "model": "claude-opus-4.5",
  "tool": "opencode",
  "project": "/path/to/project",
  "commits": ["abc123", "def456"],
  "files_modified": ["src/auth.ts", "src/reset.ts"],
  "conversation_summary": "Implemented user authentication and password reset"
}
```

This is not implemented in the current version but could be added as an enhancement.

---

## 9. Installation

The AI commit attribution system can be installed in several ways.

### Option 1: Via setup.sh (Recommended)

The main setup script includes AI attribution as an optional step:

```bash
# Run the full setup
./tools/setup.sh

# When prompted, select "Yes" for AI commit attribution
```

### Option 2: Standalone Script

For installing just the AI attribution (without the full knowledgebase setup):

```bash
# Install (interactive)
./tools/setup-ai-attribution.sh

# Force reinstall (non-interactive)
./tools/setup-ai-attribution.sh --force

# Remove / Disable
./tools/setup-ai-attribution.sh --remove
```

### What Gets Installed

1. **Global git hooks** - Applied to all repositories via `git config --global core.hooksPath`
2. **Shell functions** - Added to `~/.bashrc` or `~/.zshrc`
3. **Helper commands** - `ai-session-start`, `ai-session-end`, `ai-session-status`
4. **OpenCode plugin** - Automatically tracks file modifications (via `plugins/` symlink)

### Disabling / Removing

If you decide you don't want AI attribution anymore:

```bash
# Remove everything (hooks, shell functions, disable plugin)
./tools/setup-ai-attribution.sh --remove
```

This will:
- Remove the global git hooks path configuration
- Delete the hooks from `~/.config/opencode/git-hooks/`
- Remove shell functions from your shell config
- Disable the OpenCode plugin (renames to `.disabled`)

After removal, restart your shell and OpenCode for changes to take effect.

To re-enable later, just run the install again:

```bash
./tools/setup-ai-attribution.sh --force
```

---

## Sources

| Source | Tier | Contribution |
|--------|------|--------------|
| [git-interpret-trailers docs](https://git-scm.com/docs/git-interpret-trailers) | 1 | Trailer syntax and configuration |
| [GitHub: Creating commits with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors) | 1 | Co-authored-by trailer format |
| [git-commit docs](https://git-scm.com/docs/git-commit) | 1 | Commit hooks, --trailer flag |
| [githooks docs](https://git-scm.com/docs/githooks) | 1 | Hook execution and environment |

**Confidence**: High - All based on official Git documentation.

---

## Open Questions

- [ ] Should AI attribution be opt-out or opt-in by default?
- [ ] How to handle commits that mix AI and human changes across files?
- [ ] Standard format for AI model identifiers across tools?
- [ ] Should there be a `.ai-attribution` config file for project-level settings?
- [ ] Integration with GitHub Actions for reporting/auditing?
