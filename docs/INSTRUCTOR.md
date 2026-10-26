# Instructor Notes

## Before the lab

- **Check the Spec Kit version pin.** The guide pins `v1.1.0`. Check
  <https://github.com/github/spec-kit/releases>; if you move to a newer tag, update it in
  `README.md` (Step 4), `docs/TROUBLESHOOTING.md` and `scripts/prereqs-check.ps1`. Do a full
  dry run on a clean Windows machine after any version change: flags and command names have
  changed between releases (e.g. `--ai` → `--integration`).
- **Ask students to do Part 1 (installs + API key) at home** before the session. Installs over
  campus Wi-Fi with 30 machines are the main time sink.
- **GitHub rate limit:** a whole lab behind one NAT IP will exceed GitHub's 60 unauthenticated
  requests/hour during `specify init`. Either have students create a personal token (see
  Troubleshooting) or have them run `specify init` at home as well.
- **Gemini API key quotas:** free-tier keys have per-minute and per-day limits. `/speckit.implement`
  is the heaviest phase. If students hit 429 errors, waiting a minute and saying `continue`
  usually works.
- **Managed lab PCs:** if students can't change execution policy or install via winget, check
  with IT beforehand, or have students use their own laptops.

## Suggested timing (2-hour session, installs done at home)

| Time | Activity |
|------|----------|
| 0:00 – 0:15 | Intro to SDD: why specs first ([WORKFLOW.md](WORKFLOW.md) intro and diagram) |
| 0:15 – 0:25 | Prereqs check, `specify init`, tour of `.specify/` and `.gemini/commands/` |
| 0:25 – 0:35 | Constitution |
| 0:35 – 0:50 | Specify: review spec.md together, find the gaps |
| 0:50 – 1:05 | Clarify: **discuss answers as a class**. Different groups deciding differently on duplicates (409 vs allow) is a great discussion point |
| 1:05 – 1:20 | Plan + tasks |
| 1:20 – 1:25 | Analyze |
| 1:25 – 1:50 | Implement + curl testing |
| 1:50 – 2:00 | Wrap-up: what did the agent get wrong, and was it the spec's fault? |

## The deliberate gaps

The `/speckit.specify` prompt intentionally leaves out:

- **Duplicates** (same title + author): reject with 409, or allow?
- **Year range**: future years? negative years?
- **Blank text**: is `"   "` a valid title?
- **Field length limits**

Samples `create-book-blank-title.json` and `create-book-future-year.json` exist so students test
whatever they decided. A student whose API accepts a blank title, while their spec says it
shouldn't, has found the core lesson by themselves.

## Grading rubric (suggested, 100 pts)

| Criterion | Points |
|-----------|--------|
| Constitution present, concrete, uses MUST/SHOULD | 10 |
| spec.md: user stories, Given/When/Then, FRs, **no tech details** | 20 |
| Clarifications section with real decisions, reflected in requirements | 15 |
| plan.md / data-model / contracts consistent with spec | 10 |
| tasks.md complete, tests before implementation | 10 |
| Analyze findings addressed (evidence in commits or reflection) | 10 |
| Working API, `uv run pytest` passes, behavior matches spec | 15 |
| REFLECTION.md: thoughtful, specific answers | 10 |

**Spec–code consistency is the main thing to check.** Pick two acceptance scenarios from the
student's `spec.md` and run them with curl. A working API that disagrees with its own spec
should lose more points than a spec-compliant API with a minor bug.

## Variations for later semesters

- Different domain per group (movies, courses, recipes) with the same structure, to reduce copying.
- Second feature through the full workflow (PUT/DELETE, search, SQLite persistence).
- Have groups swap specs: group A implements group B's spec without talking to them. Ambiguities
  surface immediately.
