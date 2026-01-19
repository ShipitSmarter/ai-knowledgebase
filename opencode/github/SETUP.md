# GitHub CLI Setup

Reference guide for setting up and configuring the GitHub CLI (`gh`) for use with AI agents and automation.

## Installation

### macOS
```bash
brew install gh
```

### Linux (Debian/Ubuntu)
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

### Windows
```powershell
winget install GitHub.cli
```

## Authentication

### Basic Authentication

```bash
gh auth login
```

Follow the prompts to authenticate via browser or token.

### Check Current Auth Status

```bash
gh auth status
```

Shows logged-in account, active scopes, and token info.

## Scopes

The default authentication includes basic repository access. Additional scopes may be needed for specific operations.

### Adding Scopes

```bash
gh auth refresh -s <scope1>,<scope2>
```

### Common Scopes

| Scope | Required For |
|-------|--------------|
| `repo` | Repository access (default) |
| `read:org` | Organization membership (default) |
| `project` | GitHub Projects (new) - create/edit project items |
| `read:project` | GitHub Projects (new) - read-only access |
| `gist` | Gist access |
| `admin:org` | Organization admin operations |
| `delete_repo` | Delete repositories |

### Example: Add Project Scope

```bash
gh auth refresh -s project
```

After running, verify with:

```bash
gh auth status
# Should show 'project' in Token scopes
```

## Common Operations

### Repository Operations

```bash
# List repos in an organization
gh repo list <org> --limit 20

# Clone a repository
gh repo clone <owner>/<repo>

# View repo info
gh repo view <owner>/<repo>
```

### Issue Operations

```bash
# List issues
gh issue list --repo <owner>/<repo>

# Create issue
gh issue create --repo <owner>/<repo> --title "Title" --body "Body"

# View issue
gh issue view <number> --repo <owner>/<repo>

# Comment on issue
gh issue comment <number> --repo <owner>/<repo> --body "Comment"

# Close issue
gh issue close <number> --repo <owner>/<repo>

# Edit issue
gh issue edit <number> --repo <owner>/<repo> --title "New title"
gh issue edit <number> --repo <owner>/<repo> --add-label "bug"
```

### Pull Request Operations

```bash
# List PRs
gh pr list --repo <owner>/<repo>

# Create PR
gh pr create --title "Title" --body "Body"

# View PR
gh pr view <number>

# Merge PR
gh pr merge <number>
```

### Project Operations

Requires `project` scope.

```bash
# List projects
gh project list --owner <org>

# View project
gh project view <number> --owner <org>

# List project fields
gh project field-list <number> --owner <org>

# Add issue to project
gh project item-add <number> --owner <org> --url <issue-url>
```

## Troubleshooting

### "Resource not accessible by integration"

Missing required scope. Add the needed scope:

```bash
gh auth refresh -s <scope>
```

### "Projects (classic) is being deprecated"

This warning appears when using old project commands. Use `gh project` commands for new Projects experience.

### "Token scopes missing"

Check current scopes and add missing ones:

```bash
gh auth status
gh auth refresh -s <missing-scope>
```

### Rate Limiting

GitHub API has rate limits. Check remaining:

```bash
gh api rate_limit
```

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `GH_TOKEN` | Override authentication token |
| `GH_HOST` | Set GitHub host (for GHES) |
| `GH_REPO` | Set default repository |
| `GH_EDITOR` | Editor for interactive commands |

## Resources

- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub CLI Releases](https://github.com/cli/cli/releases)
- [GitHub API Documentation](https://docs.github.com/en/rest)
