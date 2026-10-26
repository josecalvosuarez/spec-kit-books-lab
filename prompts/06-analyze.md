# 6. Analyze

**Goal:** a read-only consistency check across constitution, spec, plan and tasks.
See [WORKFLOW.md § 6](../docs/WORKFLOW.md#6-analyze-speckitanalyze).

## Prompt

```text
/speckit.analyze
```

## After this phase, check

- Read the report. Note every **CRITICAL** and **HIGH** finding.
- For each one, decide where the fix belongs (usually `spec.md` or `plan.md`), and ask the agent
  to fix it there, for example:
  `Fix finding A2: add a task for the 404 case of GET /books/{id} in tasks.md.`
- If you changed the spec or plan significantly, re-run `/speckit.tasks`, then `/speckit.analyze`
  again until there are no CRITICAL/HIGH issues.
- Write in `REFLECTION.md` what analyze found and what you changed.
- Commit: `git commit -am "fix analyze findings"`
