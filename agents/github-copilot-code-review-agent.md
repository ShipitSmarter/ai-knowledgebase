# Agent Name: GitHub Copilot Code Review Agent

## Overview

A custom GitHub Copilot agent configured to perform thorough code reviews, focusing on code quality, security, best practices, and maintainability.

## Configuration

### Basic Settings
- **Model**: GitHub Copilot
- **Context**: Full PR diff and related files
- **Focus Areas**: Security, Performance, Best Practices, Code Style

### Custom Instructions

```
You are an expert code reviewer. When reviewing code:
1. Check for security vulnerabilities (SQL injection, XSS, authentication issues)
2. Identify performance bottlenecks
3. Ensure code follows best practices and design patterns
4. Verify proper error handling
5. Check for code duplication
6. Validate test coverage
7. Review documentation and comments
8. Ensure consistent code style
```

## Use Cases

1. **Pull Request Reviews**: Automated first-pass review of all PRs
2. **Pre-commit Checks**: Local review before committing code
3. **Refactoring Validation**: Ensure refactored code maintains quality

## Setup Instructions

1. Add the custom instructions to your GitHub Copilot settings
2. Enable the agent for your repository
3. Configure the agent to run on PR creation/update
4. Set up notification preferences for review comments

## Example Interactions

### Example 1: Security Issue Detection

**Input:**
```python
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)
```

**Output:**
```
⚠️ Security Issue: SQL Injection Vulnerability

This code is vulnerable to SQL injection. The user_id is directly 
interpolated into the SQL query.

Recommended fix:
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = ?"
    return db.execute(query, (user_id,))
```

## Performance Notes

- **Strengths**: 
  - Fast response time
  - Catches common security issues
  - Provides actionable suggestions
  
- **Limitations**: 
  - May not understand domain-specific context
  - Requires human review for final decision
  
- **Best Practices**: 
  - Use in combination with human review
  - Train on your codebase patterns
  - Regularly update custom instructions

## Integration

How to integrate this agent into existing workflows:
- Add to GitHub Actions workflow for PR checks
- Use as pre-commit hook
- Integrate with code review dashboard

## Maintenance

- **Last Updated**: 2026-01-12
- **Maintained By**: Engineering Team
- **Review Frequency**: Quarterly

## Related Resources

- [Code Review Workflow](../workflows/code-review-workflow.md)
- [Security Best Practices Research](../research/security-best-practices.md)
