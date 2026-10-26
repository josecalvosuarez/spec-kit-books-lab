# 3. Clarify

**Goal:** let the agent interview you about ambiguities, and write your decisions into the spec.
See [WORKFLOW.md § 3](../docs/WORKFLOW.md#3-clarify-speckitclarify).

## Prompt

```text
/speckit.clarify Focus on edge cases and validation rules for registering books, especially: what counts as a duplicate book and what should happen when one is submitted, valid ranges for the publication year, and whether empty or whitespace-only text is acceptable.
```

The agent will ask you questions **one at a time**, usually with options and a recommendation.
**Think before answering.** Write down each question and your answer: you'll need them for
`REFLECTION.md`.

Suggested reasoning (you may decide differently, but justify it):

| Question area | Things to consider |
|---|---|
| Duplicates | Same title + same author? Case-insensitive? Reject (409 Conflict) or allow (a library can own two copies)? |
| Year | Can a book be from the future? Year 0? Negative years (ancient texts)? |
| Text fields | Is `"   "` a valid title? Trim whitespace? Maximum length? |

## After this phase, check

- `spec.md` now has a **Clarifications** section with a dated session and your Q&A.
- The requirements and acceptance scenarios were **updated** to reflect your answers (not just
  the Q&A appended at the bottom).
- If something important wasn't asked, run clarify again or ask directly:
  `Update spec.md: duplicate books (same title and author, case-insensitive) must be rejected with a conflict error.`
- Commit: `git commit -am "spec: clarified"`
