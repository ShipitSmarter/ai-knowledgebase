# VS Code + OpenCode + GitHub Copilot Setup

A workflow combining VS Code's GUI, GitHub Copilot for inline assistance, and OpenCode for complex terminal-based AI tasks.

## Overview

| Tool | Best For |
|------|----------|
| **GitHub Copilot** | Inline completions, quick edits, chat in editor |
| **OpenCode** | Complex refactoring, multi-file changes, codebase exploration |
| **VS Code** | Editing, debugging, git integration, extensions |

## Installation

### 1. GitHub Copilot

```bash
# Install via VS Code Extensions
# Search: "GitHub Copilot" and "GitHub Copilot Chat"
```

Or via CLI:
```bash
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
```

### 2. OpenCode

```bash
# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Or with npm
npm install -g @anthropic/opencode
```

### 3. Recommended VS Code Extensions

```bash
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension ms-vscode.vscode-terminal-tabs
code --install-extension eamodio.gitlens
```

## Configuration

### VS Code Settings

Copy to your `settings.json`:

```jsonc
{
  // Terminal setup for OpenCode
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.profiles.linux": {
    "opencode": {
      "path": "bash",
      "args": ["-c", "opencode"],
      "icon": "robot"
    }
  },
  
  // Copilot settings
  "github.copilot.enable": {
    "*": true,
    "markdown": true,
    "plaintext": false
  },
  
  // Editor settings for AI assistance
  "editor.inlineSuggest.enabled": true,
  "editor.suggestSelection": "first",
  
  // Show terminal tabs for easy switching
  "terminal.integrated.tabs.enabled": true
}
```

### Keyboard Shortcuts

Add to `keybindings.json`:

```jsonc
[
  // Quick access to OpenCode terminal
  {
    "key": "ctrl+shift+o",
    "command": "workbench.action.terminal.newWithProfile",
    "args": { "profileName": "opencode" }
  },
  
  // Toggle between editor and terminal
  {
    "key": "ctrl+`",
    "command": "workbench.action.terminal.toggleTerminal"
  },
  
  // Copilot shortcuts (defaults)
  // Tab - Accept suggestion
  // Ctrl+Enter - Open Copilot completions panel
  // Ctrl+I - Copilot Chat inline
]
```

## Workflow: When to Use What

### Use GitHub Copilot When:
- Writing new code inline
- Quick function completions
- Simple refactoring within a file
- Generating docstrings/comments
- Quick questions about selected code

### Use OpenCode When:
- Complex multi-file refactoring
- Exploring unfamiliar codebase
- Running and fixing tests iteratively
- Git operations and commit messages
- Tasks requiring shell access
- Long-running autonomous tasks

## Combined Workflow Example

```
1. Open project in VS Code
2. Use Copilot Chat to understand the codebase
3. Start writing code with Copilot inline suggestions
4. For complex changes, open OpenCode terminal (Ctrl+Shift+O)
5. Ask OpenCode to refactor across files
6. Review changes in VS Code's git diff view
7. Use Copilot Chat to explain the changes if needed
8. Commit with OpenCode or VS Code git integration
```

## Tips

### Split Terminal View
Keep OpenCode running in a split terminal while coding:
1. Open terminal (`Ctrl+``)
2. Click the split icon or `Ctrl+Shift+5`
3. Run `opencode` in one pane
4. Use the other for regular commands

### Copilot + OpenCode Context Sharing
When switching from Copilot to OpenCode:
1. Copy the file path or relevant code
2. In OpenCode, reference with: "Look at `src/file.ts` line 50-80"
3. OpenCode will read the file and understand context

### File Watching
VS Code auto-reloads files when OpenCode modifies them. Enable:
```jsonc
{
  "files.watcherExclude": {
    // Remove any paths OpenCode might modify
  }
}
```

## Troubleshooting

### Copilot not suggesting?
- Check you're signed in: `Ctrl+Shift+P` > "GitHub Copilot: Sign In"
- Verify file type is enabled in settings
- Check Copilot status in bottom bar

### OpenCode terminal issues?
- Ensure `opencode` is in PATH
- Try running `which opencode` in regular terminal
- Check API keys are set in environment

## Related Files

- [settings.json](./settings.json) - VS Code settings
- [keybindings.json](./keybindings.json) - Keyboard shortcuts
- [extensions.json](./extensions.json) - Recommended extensions
