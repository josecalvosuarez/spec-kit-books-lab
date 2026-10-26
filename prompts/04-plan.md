# 4. Plan

**Goal:** decide HOW to build it: structure, data model, API contract, tests.
See [WORKFLOW.md § 4](../docs/WORKFLOW.md#4-plan-speckitplan).

## Prompt

```text
/speckit.plan Use Python 3.11+, FastAPI and Pydantic v2, managed with uv (pyproject.toml). Store books in an in-memory structure inside the application; identifiers are sequential integers starting at 1. Project layout: app/main.py (FastAPI app and routes), app/models.py (Pydantic models), tests/test_books.py (pytest + FastAPI TestClient). Endpoints: GET /books, GET /books/{id}, POST /books (returns 201 Created). Keep it as simple as the constitution requires: no database, no extra layers. Include a quickstart that shows how to run the app and test every endpoint with curl from Windows CMD using JSON files in a samples folder (curl -d @samples\file.json).
```

## After this phase, check

Open the files in `specs/001-*/`:

- `plan.md`: does the **Constitution Check** pass? Any violations must be justified.
- `data-model.md`: fields and validation rules match your **clarify** decisions?
- `contracts/`: every endpoint and **every status code** from the spec is present?
  (200, 201, 404, 422, and 409 if you decided duplicates are rejected.)
- `quickstart.md`: commands work on Windows CMD?
- Did the agent add things you didn't ask for (database, Docker, auth, extra layers)? Push back.
- Commit: `git add -A` then `git commit -m "plan"`
