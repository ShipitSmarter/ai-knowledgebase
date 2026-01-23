---
description: Name this session following conventional commit style
---

Set the session name to: $ARGUMENTS

## Session Naming Convention

Use meaningful names that follow these formats:

### PR Reviews
- `review PR #123` - When reviewing a pull request

### Development Work (Conventional Commit Style)
- `fix(scope): description` - Bug fixes
- `feat(scope): description` - New features  
- `refactor(scope): description` - Code refactoring
- `docs(scope): description` - Documentation changes
- `test(scope): description` - Test additions/changes
- `chore(scope): description` - Maintenance tasks

### Examples
- `/name review PR #456`
- `/name fix(input): type validation issue`
- `/name feat(auth): add OAuth support`
- `/name refactor(rates): simplify calculation logic`
- `/name docs(api): update endpoint documentation`

Keep descriptions concise (under 50 characters).
