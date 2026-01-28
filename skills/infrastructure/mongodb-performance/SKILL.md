---
name: mongodb-performance
description: MongoDB performance diagnostics and query-shape optimization for Viya services. Use to find/fix N+1 (looped DB calls), validate index usage with explain, and keep queries scalable on large datasets.
---

# MongoDB Performance Skill

> Note: This skill is mirrored into `.opencode/skills/mongodb-performance/SKILL.md` so OpenCode can load it in this repo.

Use this skill when you are:

- investigating slow endpoints or timeouts
- changing repository/query code (especially in viya-core)
- seeing repeated MongoDB calls in logs/APM
- trying to prevent performance regressions during feature work

## Golden rule

**Always validate performance changes with measurement** (query count + explain plans). Do not rely on intuition.

## Workflow

### 1) Detect N+1 / looped DB calls (highest impact)

The most common MongoDB performance regression is a *fast query called in a loop*.

Look for:

- `foreach` / `.Select(async ...)` / `.ForEach(...)` with `await` inside
- “enrichment” helpers (`GetLatest…`, `Enrich…`, `BuildSummary…`) that do DB work
- repository methods that accept a single id (`GetById`) being called repeatedly

Fix pattern:

1. Collect all ids first (`Distinct()` them).
2. Replace per-item reads with **set-based queries** (`$in` / aggregation) and map results back.
3. Keep projections tight.
4. Validate that each batch query uses an index with `explain`.

If the `$in` list is large:

- chunk ids (bounded batch size) and merge results
- do not depend on `$in` ordering; map by id and re-assemble

### 2) Validate query shapes with `explain`

Use `explain` to confirm:

- you avoid `COLLSCAN` on large collections
- `totalDocsExamined` and `totalKeysExamined` are proportional to `nReturned`
- sorting/pagination uses an index (or becomes expensive quickly)

MongoDB docs: https://www.mongodb.com/docs/manual/reference/explain-results/

### 3) Regex and text-like search

Rules of thumb:

- **Case-sensitive** `$regex` can use indexes.
- **Anchored prefix regex** (`^` or `\\A`) enables additional optimization.
- **Case-insensitive** `$regex` typically cannot benefit from case-insensitive indexes because `$regex` is not collation-aware.

MongoDB docs: https://www.mongodb.com/docs/manual/reference/operator/query/regex/

### 4) Aggregation pipeline performance

- push `$match` early (or ensure it can be moved early by optimizer)
- avoid pipelines that create huge intermediate results (`$lookup` + `$unwind` explosions)
- use `aggregate(..., { explain: true })` to verify pipeline and index usage

MongoDB docs: https://www.mongodb.com/docs/manual/core/aggregation-pipeline-optimization/

### 5) Index usage: validate with `$indexStats`

Use `$indexStats` to confirm new/changed query patterns are actually using the expected indexes.

MongoDB docs: https://www.mongodb.com/docs/manual/reference/operator/aggregation/indexStats/

## Guardrails for Viya services

- **Batch at the highest layer** possible (reduce network + serialization overhead), not just inside a repository.
- Avoid copying index lists into docs; index definitions change. Treat indexes as a living contract and verify with `explain`.
- Testing: validate on production-shaped, large datasets early.
