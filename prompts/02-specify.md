# 2. Specify

**Goal:** describe WHAT the API does and WHY, with no technology details.
See [WORKFLOW.md § 2](../docs/WORKFLOW.md#2-specify-speckitspecify).

> Note: this description is **intentionally incomplete** in a few places. That's on purpose:
> the next step (`/speckit.clarify`) is about finding and resolving those gaps.

## Prompt

```text
/speckit.specify Build a Books API for a small community library. Librarians need to register the books the library owns and look them up later.

A book has a title, an author and a publication year. Each book gets a unique identifier assigned by the system when it is registered.

Users must be able to:
- Register a new book by providing its title, author and publication year. The response returns the stored book including its identifier.
- List all registered books.
- Retrieve a single book by its identifier. If no book has that identifier, they get a clear "not found" error.

Title and author are required. If required information is missing or invalid, the book is rejected with a clear error explaining what is wrong.

Data does not need to survive a restart of the service for this first version.
```

## After this phase, check

- A new branch was created (`git branch` shows something like `001-books-api`).
- Open `specs/001-*/spec.md`:
  - Are there **user stories** with **Given/When/Then** acceptance scenarios?
  - Are there **functional requirements** (FR-001, FR-002, …)?
  - Is there **any** technology in it (FastAPI, Python, dictionary, JSON schema, file paths)?
    If so, ask the agent to remove it.
  - Look for `[NEEDS CLARIFICATION]` markers. Write them down. Compare with what clarify asks.
- Think: what did we **not** say? (Hint: duplicates? year range? empty strings? max length?)
- Commit: `git commit -am "spec"` (use `git add -A` first if new files were created)
