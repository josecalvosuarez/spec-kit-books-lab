# 1. Constitution

**Goal:** define the rules every phase must follow (stack, quality, testing, simplicity).
See [WORKFLOW.md § 1](../docs/WORKFLOW.md#1-constitution-speckitconstitution).

## Prompt

```text
/speckit.constitution Create the constitution for a small educational REST API project. Principles:

1. Technology: Python 3.11+ with FastAPI and Pydantic. Dependencies and commands are managed with uv (pyproject.toml). The app MUST be runnable with "uv run uvicorn app.main:app --reload --port 8000" and the application object MUST live in app/main.py.
2. Simplicity first: this is a learning project. Use the smallest design that satisfies the spec. No databases, no Docker, no authentication, no extra layers (repositories, services, factories) unless a spec explicitly requires them. Data is stored in memory unless a spec says otherwise.
3. Test-first: every endpoint MUST have automated tests with pytest and FastAPI's TestClient, covering the success case and every documented error case. Tests MUST be runnable with "uv run pytest" and MUST pass before a task is considered done.
4. Explicit API contract: every endpoint documents its request body, response body and every possible HTTP status code. Responses are JSON. Error responses have a consistent JSON shape.
5. Input validation: all client input MUST be validated; invalid input returns HTTP 422 with a clear message. The server MUST never return a 500 for bad client input.
6. Readability: code is written for students to read. Clear names, type hints everywhere, short functions, a brief docstring per endpoint. No clever tricks.
7. Windows-friendly: all documented commands MUST work in Windows CMD and PowerShell. Do not rely on bash-only tools.
```

## After this phase, check

- Open `.specify/memory/constitution.md`. Are all 7 principles there, with MUST/SHOULD wording?
- Is anything there that you did **not** ask for? Remove it or ask why it's there.
- Commit: `git add -A` then `git commit -m "constitution"`
