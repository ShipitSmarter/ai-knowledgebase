---
description: Diff branch to main and refactor changed C# files to match backend coding standards (dotnet repos only)
---

# Backend Diff Refactor

Apply coding standards and best practices to all changed C# files in the current branch compared to `main`.

---

## Prerequisite Check

**This command is only for ShipitSmarter .NET backend repositories.**

Before executing, verify this is a .NET backend codebase by checking for:
- `*.sln` solution file in the repository root
- `src/` directory with C# projects (`*.csproj`)
- Typical structure: `src/{Service}.Api/`, `src/{Service}.Core/`, `src/{Service}.Contracts/`

**If this is NOT a .NET backend repository, stop and inform the user.**

---

## Load Structure Skill

Based on the repository, load the appropriate structure skill:

| Repository | Skill to Load |
|------------|---------------|
| `rates` | `rates-structure` |
| `shipping` | `shipping-structure` |
| Other .NET repos | Use patterns from both as general guidance |

---

## Workflow

| Step | Action | Command/Tool |
|------|--------|--------------|
| 1 | Identify repository | Check `*.sln` name |
| 2 | Load structure skill | `skill rates-structure` or `skill shipping-structure` |
| 3 | Get changed files | `git diff --name-only main...HEAD -- '*.cs'` |
| 4 | Analyze each file | Read and check against standards |
| 5 | Apply fixes | Edit files to comply |
| 6 | Verify | `/home/bram/.dotnet/dotnet build` |

---

## C# Coding Standards Checklist

For each changed `.cs` file, verify:

### General Conventions
- [ ] File-scoped namespaces (single line `namespace X;`)
- [ ] Primary constructors for dependency injection
- [ ] Collection expressions (`[]` syntax) for list/array initialization
- [ ] Expression-bodied members where appropriate
- [ ] `var` for local variables when type is obvious
- [ ] Nullable reference types used correctly
- [ ] `ConvertAll()` over `Select().ToList()` for list transformations
- [ ] `record` types for immutable DTOs
- [ ] Single-line code blocks without braces (but with newline/indentation)

### Naming Conventions
- [ ] Interfaces use `I` prefix (`IGetRatesUseCase`)
- [ ] Async methods use `Async` suffix (`GetDistanceAsync`)
- [ ] Private fields use `_` prefix (`_distanceProvider`)
- [ ] Constants use `PascalCase`

### Contract Classes (in `*.Contracts` projects)
- [ ] All public properties have XML `<summary>` documentation
- [ ] No explicit constructors - use `required` properties instead
- [ ] Exception: Base class inheritance (e.g., `ListWrapper<T>`)

### Architecture Patterns
- [ ] Controllers are thin - delegate to use cases via `[FromServices]`
- [ ] Use cases contain single business operation
- [ ] Database logic only in repository layer
- [ ] Constants defined once (avoid duplicating collection names, etc.)
- [ ] Enums stay as enums (no unnecessary `.ToString()`)

### LINQ Best Practices
- [ ] `Where` + `Select` over `SelectMany` with conditionals
- [ ] No unnecessary intermediate collections

---

## Architecture Review

For each **new or modified file**, evaluate:

### 1. Use Case vs Service

**Question:** Is this logic in the right place?

| Use Cases | Services |
|-----------|----------|
| Single operation logic | Shared/reusable logic |
| Auto-registered | Must register in DI |
| Called from controllers | Called from use cases |
| One public method (`Handle`) | Multiple methods allowed |

### 2. Repository Layer

**Question:** Is database logic properly encapsulated?

- All MongoDB queries should use repository methods
- Use `repository.Filter` not `Builders<T>.Filter`
- No direct database access in use cases or handlers

### 3. Mapper Consistency

**Question:** Are Contract <-> Core mappings complete?

When adding new properties:
1. Add to both Contract and Core entity
2. Add mapping in both `ToCore` and `ToContract` files
3. Handle nullable types appropriately

---

## Verification Commands

```bash
# Build entire solution (must pass)
/home/bram/.dotnet/dotnet build

# Run tests related to changed files (optional but recommended)
/home/bram/.dotnet/dotnet test test/{Service}.Tests --filter "TestClassName"
```

Build must pass with no new errors or warnings introduced by changes.

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **rates-structure** | Working in the Rates repository |
| **shipping-structure** | Working in the Shipping repository |
| **dotnet-testing** | Running and debugging .NET tests |
