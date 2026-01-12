# OpenCode Terminal Setup

Pure terminal workflow for OpenCode without an IDE. Ideal for remote servers, minimal setups, or terminal-first developers.

## Installation

```bash
# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Or with npm
npm install -g @anthropic/opencode

# Verify installation
opencode --version
```

## Configuration

### Environment Variables

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# OpenCode configuration
export ANTHROPIC_API_KEY="your-api-key"

# Optional: Default model
export OPENCODE_MODEL="claude-sonnet-4-20250514"

# Optional: Auto-approve safe operations
export OPENCODE_AUTO_APPROVE="true"
```

### OpenCode Config File

Create `~/.config/opencode/config.json`:

```jsonc
{
  "model": "claude-sonnet-4-20250514",
  "theme": "dark",
  "autoApprove": ["read", "glob", "grep"],
  "mcpServers": {
    // Add your MCP servers here
  }
}
```

### Project-Level Config

Create `.opencode/config.json` in your project root:

```jsonc
{
  "instructions": "This is a TypeScript project using pnpm. Follow existing code style.",
  "mcpServers": {
    // Project-specific MCP servers
  }
}
```

## Terminal Multiplexer Setup

### tmux Configuration

Add to `~/.tmux.conf`:

```bash
# Easy pane splitting
bind | split-window -h
bind - split-window -v

# Quick opencode session
bind o new-window -n 'opencode' 'opencode'

# Mouse support for easier navigation
set -g mouse on

# Keep plenty of history for opencode output
set -g history-limit 50000
```

**Workflow:**
```bash
# Start tmux session
tmux new -s dev

# Split: code on left, opencode on right
Ctrl+b |          # Split vertically
opencode          # Run in right pane
Ctrl+b ←          # Switch to left pane for editing
```

### Zellij Configuration

Create `~/.config/zellij/layouts/opencode.kdl`:

```kdl
layout {
    pane split_direction="vertical" {
        pane size="60%" {
            command "nvim"
            args "."
        }
        pane size="40%" {
            command "opencode"
        }
    }
}
```

**Start with:**
```bash
zellij --layout opencode
```

## Shell Aliases

Add to your shell config:

```bash
# Quick opencode access
alias oc='opencode'
alias occ='opencode --continue'  # Continue last session

# Start opencode in project context
ocproj() {
    cd "$1" && opencode
}

# Opencode with specific model
ocfast() {
    OPENCODE_MODEL="claude-3-5-haiku-20241022" opencode "$@"
}

# Open file in opencode context
ocfile() {
    opencode "Look at $1 and explain what it does"
}
```

## Recommended Tools

| Tool | Purpose | Install |
|------|---------|---------|
| **fzf** | Fuzzy file finding | `apt install fzf` |
| **ripgrep** | Fast code search | `apt install ripgrep` |
| **bat** | Syntax-highlighted cat | `apt install bat` |
| **delta** | Better git diffs | `cargo install git-delta` |
| **lazygit** | Terminal git UI | `go install github.com/jesseduffield/lazygit@latest` |

## Workflow Examples

### Basic Session
```bash
cd ~/projects/my-app
opencode
> Explore this codebase and explain the architecture
> Find and fix any TypeScript errors
> Write tests for the auth module
```

### Multi-Pane Workflow
```
┌─────────────────────────────────────────┐
│  Editor (vim/nvim)      │  OpenCode    │
│                         │              │
│  - View/edit files      │  - AI tasks  │
│  - Quick changes        │  - Explore   │
│                         │  - Refactor  │
├─────────────────────────┴──────────────┤
│  Regular shell                          │
│  - git commands, tests, builds          │
└─────────────────────────────────────────┘
```

### Remote Server Workflow
```bash
# SSH into server
ssh user@server

# Start persistent session
tmux new -s opencode-work

# Run opencode
cd /var/www/app
opencode

# Detach (Ctrl+b d) and reconnect later
tmux attach -t opencode-work
```

## Tips

### Copy/Paste with Terminal
- Most terminals: `Ctrl+Shift+C` / `Ctrl+Shift+V`
- tmux: Enter copy mode with `Ctrl+b [`, select text, press `Enter`
- Use `xclip` or `pbcopy` for piping: `cat file | xclip -selection clipboard`

### Quick Context Sharing
```bash
# Share file content with opencode
cat src/important.ts  # Then copy output to paste into opencode

# Or ask opencode directly
> Read src/important.ts and explain the main function
```

### Session Continuity
```bash
# List previous sessions
opencode sessions

# Continue a specific session
opencode --session <session-id>

# Continue the last session
opencode --continue
```

## Troubleshooting

### "command not found: opencode"
```bash
# Check if installed
which opencode

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### API Key Issues
```bash
# Verify key is set
echo $ANTHROPIC_API_KEY

# Test API access
curl -H "x-api-key: $ANTHROPIC_API_KEY" \
  https://api.anthropic.com/v1/messages \
  -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}'
```

### Terminal Rendering Issues
```bash
# Ensure UTF-8 locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Use a modern terminal emulator (kitty, alacritty, wezterm)
```
