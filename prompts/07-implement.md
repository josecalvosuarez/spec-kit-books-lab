# 7. Implement

**Goal:** the agent builds the code by executing tasks.md.
See [WORKFLOW.md § 7](../docs/WORKFLOW.md#7-implement-speckitimplement).

## Prompt

```text
/speckit.implement Execute the tasks in order. After finishing each phase of tasks.md, run "uv run pytest" and show me the result before continuing. Mark tasks as completed in tasks.md as you go.
```

## While it runs

- **Read every approval request** before accepting. Which files? Which commands?
- If it does something not in `tasks.md`, press **Esc** and redirect it.
- If it's slow or hits quota errors, wait and say `continue`.

## After this phase, check

In a second terminal, in the project folder:

```cmd
uv run pytest
uv run uvicorn app.main:app --reload --port 8000
```

Then, in a third terminal, run **all the curl tests from the main README (Step 10)** and compare
each response to `spec.md`:

| Test | Expected (per your spec) | Actual |
|------|--------------------------|--------|
| List empty | 200, `[]` | |
| Create book | 201, book with id | |
| Get by id | 200, the book | |
| Unknown id | 404 | |
| Missing title | 422 | |
| Duplicate | (your clarify decision) | |

Any mismatch? Decide: is the **code** wrong (fix the code) or the **spec** wrong (fix the spec
first, then the code)? Never leave them disagreeing.

- Every task in `tasks.md` is checked `[X]`.
- Commit: `git add -A` then `git commit -m "implement books api"`
