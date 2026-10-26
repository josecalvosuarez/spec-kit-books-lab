# Spec-Driven Development Lab: Books API with Spec Kit + Gemini CLI (Windows)

In this lab you will build a small REST API **without writing the code first**. Instead, you will
write a *specification* of what you want, let an AI agent turn it into a plan and a task list, and
only then let it implement the code. This is **Spec-Driven Development (SDD)**, and the tool we use
for it is GitHub's **Spec Kit**.

- Spec Kit: <https://github.com/github/spec-kit>
- Spec Kit docs: <https://github.github.com/spec-kit/>
- Gemini CLI: <https://github.com/google-gemini/gemini-cli>

**What you'll build:** a *Books API* in **Python + FastAPI** with three endpoints:

| Method | Path          | Purpose                    |
|--------|---------------|----------------------------|
| GET    | `/books`      | List all books             |
| GET    | `/books/{id}` | Get one book by id         |
| POST   | `/books`      | Create a new book          |

**What you'll learn:** the SDD workflow — *constitution → specify → clarify → plan → tasks →
analyze → implement* — and why each step exists. The *why* is explained in
[`docs/WORKFLOW.md`](docs/WORKFLOW.md). Read it alongside this guide.

> ⏱️ Expected time: ~30 min for setup, ~60–90 min for the SDD workflow.

---

## Repository contents

```
README.md                  ← you are here: step-by-step setup and lab guide
docs/WORKFLOW.md           ← each SDD phase explained: purpose, outputs, best practices
docs/TROUBLESHOOTING.md    ← common Windows problems and fixes
prompts/                   ← copy-paste prompts for each phase, in order
samples/                   ← JSON payloads for testing the API with curl
scripts/prereqs-check.ps1  ← verifies your machine is ready
docs/INSTRUCTOR.md         ← notes for the instructor (timing, grading, version pin)
```

---

## Part 1 — Install the tools

All commands below work in **Command Prompt (CMD)** or **PowerShell**. Where they differ, both
versions are shown.

> ⚠️ **After every install step, close and reopen your terminal.** Windows only reloads `PATH`
> in new terminal windows. "Command not found" right after installing almost always means this.

### Step 1 — Install Git, Python, uv and Node.js

The easiest way is `winget` (built into Windows 10/11):

```cmd
winget install --id Git.Git -e
winget install --id Python.Python.3.12 -e
winget install --id astral-sh.uv -e
winget install --id OpenJS.NodeJS.LTS -e
```

| Tool    | Why we need it                                                        |
|---------|-----------------------------------------------------------------------|
| Git     | Spec Kit creates a git repo and a branch per feature                  |
| Python  | Spec Kit's CLI (`specify`) and our FastAPI app are Python (3.11+)     |
| uv      | Fast Python package/tool manager; installs `specify` and runs the app |
| Node.js | Gemini CLI is distributed through npm (Node 20+)                      |

If `winget` isn't available, download installers from git-scm.com, python.org (check **"Add
python.exe to PATH"**), docs.astral.sh/uv, and nodejs.org.

**Close and reopen your terminal**, then verify:

```cmd
git --version
python --version
uv --version
node --version
```

### Step 2 — Install Gemini CLI

```cmd
npm install -g @google/gemini-cli
gemini --version
```

### Step 3 — Get a Gemini API key and save it

1. Go to **<https://aistudio.google.com/apikey>** and sign in with your Google account.
2. Click **Create API key** and copy it.
3. Save it as a **user** environment variable (no admin rights needed):

```cmd
setx GEMINI_API_KEY "paste-your-key-here"
```

4. **Close and reopen your terminal**, then check it's set without printing the whole key:

   - CMD: `echo %GEMINI_API_KEY:~0,6%...`
   - PowerShell: `$env:GEMINI_API_KEY.Substring(0,6) + "..."`

> 🔐 **Your API key is a password.** Never paste it into code, a prompt, a screenshot, or a
> commit. If you leak it, delete it in AI Studio and create a new one.

### Step 4 — Install Spec Kit (`specify` CLI)

Install from the **official GitHub repository**, pinned to the version used in this course:

```cmd
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.1.0
uv tool update-shell
```

> ⚠️ Do **not** `pip install specify-cli` from PyPI. Packages with that name on PyPI are **not**
> the official Spec Kit.

**Close and reopen your terminal**, then verify:

```cmd
specify version
specify check
```

### Step 5 — Allow PowerShell scripts (one time)

Spec Kit's helper scripts on Windows are PowerShell (`.ps1`). Allow locally created scripts for
your user:

```cmd
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
```

### Step 6 — Run the prerequisites check

From the folder where you unzipped/cloned this lab:

```cmd
powershell -ExecutionPolicy Bypass -File scripts\prereqs-check.ps1
```

Everything should be green. Fix anything red before continuing
(see [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)).

---

## Part 2 — Create the project

### Step 7 — Initialize a Spec Kit project

Create your project **outside** this lab folder, e.g. in `C:\dev`:

```cmd
mkdir C:\dev
cd C:\dev
specify init books-api --integration gemini --script ps
cd books-api
```

- `--integration gemini` installs the `/speckit.*` commands for Gemini CLI (in `.gemini\commands\`).
- `--script ps` uses the PowerShell versions of Spec Kit's helper scripts.

> 💡 Older tutorials online use `--ai gemini`. Current Spec Kit uses `--integration`.

> 💡 If the whole class runs this at once you may get **`403 rate limit`** from GitHub.
> See [Troubleshooting](docs/TROUBLESHOOTING.md#github-403-rate-limit-during-specify-init).

Now copy the `samples` folder from this lab into your project (you'll use it for testing), and
make sure secrets and Python caches are never committed:

```cmd
xcopy /E /I "C:\path\to\this-lab\samples" samples
type "C:\path\to\this-lab\.gitignore" >> .gitignore
git add -A
git commit -m "spec kit init"
```

Take a look at what was created:

```
books-api\
├── .gemini\commands\     ← the /speckit.* slash commands for Gemini
├── .specify\
│   ├── memory\           ← constitution.md lives here
│   ├── scripts\powershell\
│   └── templates\        ← templates for spec, plan, tasks
└── samples\              ← (copied by you)
```

### Step 8 — Start Gemini CLI

```cmd
gemini
```

The first time, choose **"Use Gemini API key"** as the authentication method. It will pick up
`GEMINI_API_KEY` automatically.

Type `/` and you should see the `speckit.*` commands in the list. If not, see Troubleshooting.

> 🛑 **Approvals:** Gemini CLI asks before editing files or running commands. **Read each request
> before approving it.** Do not enable "YOLO"/auto-approve mode in this lab — reviewing what the
> agent does is part of the exercise.

---

## Part 3 — The Spec-Driven Development workflow

Run each phase **in order**, inside Gemini CLI. The full prompt for each phase is in the
[`prompts/`](prompts/) folder: open the file, copy the text, paste it into Gemini.

**After each phase, open the generated file and read it.** If something is wrong, tell the agent
to fix it *before* moving on. Errors in the spec become bugs in the code.

| # | Command                 | Prompt file                                                     | Output to review                       |
|---|-------------------------|-----------------------------------------------------------------|----------------------------------------|
| 1 | `/speckit.constitution` | [`01-constitution.md`](prompts/01-constitution.md)              | `.specify/memory/constitution.md`      |
| 2 | `/speckit.specify`      | [`02-specify.md`](prompts/02-specify.md)                        | `specs/001-.../spec.md`                |
| 3 | `/speckit.clarify`      | [`03-clarify.md`](prompts/03-clarify.md)                        | updated `spec.md` (Clarifications)     |
| 4 | `/speckit.plan`         | [`04-plan.md`](prompts/04-plan.md)                              | `plan.md`, `data-model.md`, `contracts/` |
| 5 | `/speckit.tasks`        | [`05-tasks.md`](prompts/05-tasks.md)                            | `tasks.md`                             |
| 6 | `/speckit.analyze`      | [`06-analyze.md`](prompts/06-analyze.md)                        | a report (no files changed)            |
| 7 | `/speckit.implement`    | [`07-implement.md`](prompts/07-implement.md)                    | the actual code + tests                |

> 💡 `/speckit.specify` creates a new git branch (e.g. `001-books-api`). Commit after each phase
> so you can see how the documents evolve: `git add -A && git commit -m "spec: after clarify"`.

---

## Part 4 — Run and test the API

### Step 9 — Run the tests and start the server

In a **second terminal** (leave Gemini open in the first), from `C:\dev\books-api`:

```cmd
uv run pytest
uv run uvicorn app.main:app --reload --port 8000
```

Open <http://localhost:8000/docs> in your browser — FastAPI generates interactive documentation
from your code for free.

### Step 10 — Test with curl

Windows 10 (1803+) and Windows 11 **already include curl**. Open a **third terminal**.

> ⚠️ **PowerShell users:** in Windows PowerShell 5.1, `curl` is an alias for `Invoke-WebRequest`,
> which is a different tool. Always type **`curl.exe`** in PowerShell. In CMD, `curl` is fine.

We send JSON from **files** in `samples\` using `-d @file`. This avoids the painful quote-escaping
CMD requires for inline JSON.

```cmd
:: 1. List books (should be empty: [])
curl -i http://localhost:8000/books

:: 2. Create a book (expect 201 Created)
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book.json

:: 3. Create another one
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book-2.json

:: 4. List again (should show 2 books)
curl -i http://localhost:8000/books

:: 5. Get one book by id (use an id returned in step 2)
curl -i http://localhost:8000/books/1

:: 6. Book that doesn't exist (expect 404)
curl -i http://localhost:8000/books/9999

:: 7. Invalid book: missing title (expect 422)
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book-invalid.json

:: 8. Duplicate book (expected status depends on what you decided in /speckit.clarify!)
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book.json

:: 9. Blank title "   " (expected: depends on your clarify decision)
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book-blank-title.json

:: 10. Year 3025 (expected: depends on your clarify decision)
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book-future-year.json
```

`-i` shows the HTTP status line and headers, so you can check status codes, not just bodies.

**Check each response against your `spec.md`.** If the API behaves differently from the spec, that
is a bug. Decide whether the *code* or the *spec* is wrong, fix it through the agent, and re-test.

---

## Deliverables

Push your `books-api` repository (all branches) and submit the link. It must include:

1. `.specify/memory/constitution.md`
2. `specs/001-*/` with `spec.md`, `plan.md`, `tasks.md` (and the other generated files)
3. The working code and passing tests (`uv run pytest`)
4. A commit history showing each phase (at least one commit per phase)
5. `REFLECTION.md` (½–1 page) answering:
   - What did `/speckit.clarify` ask you, and what did you decide? Why?
   - Find one place where the agent did something you didn't expect. Was the spec ambiguous,
     or did the agent ignore it?
   - What did `/speckit.analyze` report? Did you change anything because of it?
   - Would you use SDD for a real project? When would it be overkill?

> ❌ Do **not** commit any API key. `.gitignore` in your project should include `.env`.

---

## Next steps (optional challenges)

Run a **second feature** through the full workflow (it gets a new `specs/002-*` folder):

- `PUT /books/{id}` and `DELETE /books/{id}`
- Search: `GET /books?author=...`
- Persist books in SQLite instead of memory

Watch how the constitution keeps the new feature consistent with the first one.
