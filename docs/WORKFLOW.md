# The Spec-Driven Development Workflow, Step by Step

This document explains **why** each step of the lab exists, what it produces, and how to do it
well. The [README](../README.md) tells you *what to type*; this tells you *what's going on*.

Official project: <https://github.com/github/spec-kit> · Docs: <https://github.github.com/spec-kit/>

---

## Why Spec-Driven Development?

When you ask an AI agent "build me a books API", it fills every gap with a guess: which
framework, which fields, which status codes, what happens on duplicates, how to test. Some guesses
are fine. Others silently become bugs, and you only find out when you read the code (if you do).

SDD flips the order: **the specification is the primary artifact, and code is generated from it.**
You spend your effort on *what* and *why*; the agent handles *how*. Every guess the agent would
have made becomes an explicit, reviewable decision in a document.

```
 constitution ──► specify ──► clarify ──► plan ──► tasks ──► analyze ──► implement
   (rules)        (what)     (gaps)     (how)    (steps)   (check)      (code)
 └─────────── you think here ──────────┘ └──── agent proposes, you review ────┘
```

Two ideas to keep in mind through the whole lab:

1. **The spec is about WHAT and WHY, never HOW.** No framework names, no class names, no file
   paths in `spec.md`. Technology choices belong in the *plan*.
2. **Review is your job.** Each phase produces a document. Read it. A five-minute review of
   `spec.md` saves an hour of debugging generated code.

---

## 0. Setup: `specify init`

**Purpose.** Bootstraps the project: a git repository, a `.specify/` folder with templates and
helper scripts, and slash commands registered for your agent (`.gemini/commands/` for Gemini CLI).

**What it produces.**

| Path | Contents |
|------|----------|
| `.specify/memory/constitution.md` | A template for the project's rules (filled in step 1) |
| `.specify/templates/` | Templates for spec, plan, tasks, checklists |
| `.specify/scripts/powershell/` | Scripts the agent runs (create branch, set up feature folder…) |
| `.gemini/commands/` | The `/speckit.*` commands, as prompt files the agent reads |

**Best practices.**
- Pin the Spec Kit version for a team or a class so everyone gets the same templates.
- Commit right after `init`. It gives you a clean baseline to diff against.
- Open a few files in `.gemini/commands/`. The "magic" slash commands are just long, carefully
  written prompts. Understanding that demystifies the whole tool.

---

## 1. Constitution: `/speckit.constitution`

**Purpose.** Defines the **non-negotiable principles** of the project: technology constraints,
quality standards, testing rules, code style. Every later phase reads it and must comply.

Think of it as the rules a senior engineer would give a new team member on day one: *"We use
Python and FastAPI. Every endpoint has a test. We validate all input. Keep it simple."*

**Output.** `.specify/memory/constitution.md`

**Best practices.**
- **Be concrete and testable.** "Code should be good" is useless. "Every endpoint MUST have at
  least one automated test for the success case and one for each documented error" is
  enforceable.
- **Use MUST / SHOULD** language. The agent treats MUST as a gate.
- **Keep it short.** 5–8 principles. A 10-page constitution gets ignored, by agents and people.
- **Put cross-feature decisions here**, not in a spec: language, framework, test runner, how to
  run the app. It applies to *every* future feature.
- **Simplicity is a principle worth stating.** Agents love to over-engineer (repositories,
  services, factories for a 3-endpoint API). Tell it not to.

---

## 2. Specify: `/speckit.specify`

**Purpose.** Describes **what** the feature does and **why**, from the user's point of view:
user stories, acceptance scenarios, functional requirements, success criteria.

**Output.** A new git branch (e.g. `001-books-api`) and `specs/001-books-api/spec.md`. The agent
may also create `checklists/requirements.md` to self-check spec quality.

**Best practices.**
- **No tech in the spec.** If you see "FastAPI", "Pydantic", "dictionary" or a file path in
  `spec.md`, ask the agent to remove it. Tech changes; requirements shouldn't.
- **Describe behavior, including errors.** What happens on a missing field? Unknown id? The
  sad paths are where the bugs live.
- **Acceptance scenarios should be Given/When/Then** and each one should be checkable with a
  single curl command. If you can't test it, it's not specific enough.
- **Look for `[NEEDS CLARIFICATION]` markers.** The agent inserts them where it had to guess.
  They are a gift: they show you the gaps.
- **Small features.** One spec = one coherent feature. "Books API" is fine; "Books API plus
  authentication plus a frontend" is three specs.

---

## 3. Clarify: `/speckit.clarify`

**Purpose.** The agent **interviews you** about underspecified areas of the spec, asking a few
targeted questions (usually multiple choice) and writing your answers back into `spec.md` under a
*Clarifications* section.

**This is the most important step of the lab.** It is where you practice the core skill of
SDD: noticing ambiguity *before* it becomes code.

**Output.** An updated `spec.md`.

**Best practices.**
- **Run it before `/speckit.plan`.** Clarifying after planning means re-planning.
- **Don't just accept the recommended option.** Think about each question. Would a real user
  expect that behavior?
- **The prompt in this lab deliberately leaves things vague** (duplicate books, year limits,
  field lengths). If clarify doesn't ask about them, ask yourself: why not? Then add them.
- **You can run it more than once.**

---

## 4. Plan: `/speckit.plan`

**Purpose.** Now — and only now — decide **how**: tech stack, project structure, data model, API
contracts, testing approach. The plan must comply with the constitution and satisfy the spec.

**Output** (in `specs/001-books-api/`):

| File | Contents |
|------|----------|
| `plan.md` | Technical context, constitution check, project structure |
| `research.md` | Decisions made and alternatives considered |
| `data-model.md` | Entities, fields, validation rules |
| `contracts/` | API contract (often OpenAPI), the "shape" of every endpoint |
| `quickstart.md` | How to run and validate the feature |

**Best practices.**
- **Check the "Constitution Check" section.** If the plan violates a principle, it must justify
  it. Unjustified violations mean the plan is wrong.
- **Compare `contracts/` against `spec.md`.** Every status code in the spec should be in the
  contract and vice versa.
- **Watch for over-engineering.** If the plan adds a database, Docker, authentication or five
  layers of abstraction you didn't ask for, push back.
- **Read `research.md`.** It's where the agent explains its choices. If a reason is weak, challenge it.

---

## 5. Tasks: `/speckit.tasks`

**Purpose.** Breaks the plan into an **ordered, dependency-aware checklist** of small tasks,
grouped by user story. Tasks marked `[P]` can be done in parallel (they touch different files).

**Output.** `specs/001-books-api/tasks.md`

**Best practices.**
- **Each task should be small and verifiable** — roughly one file or one behavior.
- **Tests should come before implementation** (if your constitution requires test-first).
  Check the order.
- **Every requirement in the spec should map to at least one task.** If a requirement has no
  task, it won't be built.
- `tasks.md` is a checklist the agent ticks off during implement, so you can track progress.

---

## 6. Analyze: `/speckit.analyze`

**Purpose.** A **read-only consistency check** across constitution, spec, plan and tasks. It
reports duplications, ambiguities, requirements with no tasks, tasks with no requirement,
terminology drift, and constitution violations, each with a severity.

**Output.** A report in the chat. **It does not modify files.**

**Best practices.**
- **Run it after tasks and before implement.** It's the last cheap moment to fix things.
- **Fix CRITICAL and HIGH findings** before implementing. Fix them in the right document (usually
  the spec or the plan), then regenerate downstream documents if needed.
- Think of it as a code review, but for documents.

---

## 7. Implement: `/speckit.implement`

**Purpose.** The agent executes `tasks.md` in order: writes tests, writes code, runs the tests,
and ticks off tasks as it goes.

**Output.** Source code, tests, and a fully checked `tasks.md`.

**Best practices.**
- **Read every approval request.** You'll be asked before files are written and commands run.
  This is where you'd catch the agent running something unexpected.
- **If it goes off the rails, stop it** (Esc) and correct it. Point it back to the spec or a
  specific task.
- **Run the tests yourself** afterwards (`uv run pytest`). Don't trust "all tests pass" without
  seeing it.
- **Test manually with curl against the spec**, not against what you think the API should do.
- **If behavior is wrong, decide what's wrong**: the code (fix it), or the spec (update the spec
  first, then the code). Never let the spec and the code drift apart. That's the whole point.

---

## Optional extras

| Command | When to use it |
|---------|----------------|
| `/speckit.checklist` | Generate "unit tests for English": checklists that validate the *requirements* are complete and clear (e.g. an API-error-handling checklist). |
| `/speckit.taskstoissues` | Turn `tasks.md` into GitHub issues. Needs the GitHub integration. |

---

## Common anti-patterns (things to avoid)

| Anti-pattern | Why it's a problem |
|---|---|
| Skipping straight to `/speckit.implement` | You get "vibe coding" with extra paperwork. Nothing was reviewed. |
| Putting tech decisions in the spec | The spec becomes brittle and you can't rethink the stack. |
| Accepting every document without reading it | The agent's guesses become your requirements. |
| Fixing bugs only in code | The spec becomes a lie; the next feature is built on a false foundation. |
| One giant spec for everything | Clarify can't cover it, tasks become huge, analysis gets noisy. |
| Turning on auto-approve | You lose the chance to catch mistakes (and risky commands) as they happen. |
