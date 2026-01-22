---
description: Diff branch to main and refactor changed Vue/TypeScript files to match frontend coding standards (Vue repos only)
---

Load the `diff-refactor` skill and apply it to all changed files in the current branch compared to `main`.

This skill will:
1. Load the `viya-app-coding-standards` for reference
2. Get the list of changed files
3. Analyze each file for standards compliance
4. Apply fixes and verify with lint/type-check
