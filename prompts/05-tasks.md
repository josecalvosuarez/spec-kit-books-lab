# 5. Tasks

**Goal:** break the plan into small, ordered, verifiable tasks.
See [WORKFLOW.md § 5](../docs/WORKFLOW.md#5-tasks-speckittasks).

## Prompt

```text
/speckit.tasks Order tasks so that tests are written before the implementation they verify, as the constitution requires.
```

## After this phase, check

Open `specs/001-*/tasks.md`:

- Tasks are numbered (T001, T002…), grouped in phases / by user story.
- **Tests come before implementation** for each endpoint.
- Pick 3 functional requirements from `spec.md` (FR-00x). Can you find a task for each?
- Are tasks small (one file or one behavior each)? Split any that are huge.
- `[P]` marks tasks that can run in parallel. Do they really touch different files?
- Commit: `git add -A` then `git commit -m "tasks"`
