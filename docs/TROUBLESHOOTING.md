# Troubleshooting (Windows)

Before anything else, run the checker from the lab folder:

```cmd
powershell -ExecutionPolicy Bypass -File scripts\prereqs-check.ps1
```

---

## "'xyz' is not recognized as an internal or external command"

You installed something but the terminal doesn't see it.

1. **Close all terminals and open a new one.** (This fixes it 90% of the time.)
2. For `specify`, run `uv tool update-shell`, then reopen the terminal.
3. For `gemini`, check that npm's global folder is on PATH: run `npm prefix -g` and make sure
   that folder (usually `%APPDATA%\npm`) is in your user `Path` variable.
4. For `python`: if typing `python` opens the **Microsoft Store**, go to *Settings → Apps →
   Advanced app settings → App execution aliases* and turn off the two `python` aliases.

## `curl` in PowerShell does something weird / asks for "Uri"

In Windows PowerShell 5.1, `curl` is an alias for `Invoke-WebRequest`. Use **`curl.exe`**:

```powershell
curl.exe -i http://localhost:8000/books
```

In CMD, plain `curl` is the real curl. Check you have it with `curl --version`. It ships with
Windows 10 version 1803 and later. If it's somehow missing: `winget install cURL.cURL`.

## `curl` POST returns 422 or "JSON decode error"

Usually a quoting problem. Don't fight CMD's quoting: put the JSON in a file and use `-d @file`:

```cmd
curl -i -X POST http://localhost:8000/books -H "Content-Type: application/json" -d @samples\create-book.json
```

Also check:
- You included `-H "Content-Type: application/json"`.
- The path to the file is right (you're in the project folder and `samples\` exists there).
- If you edited the JSON in Notepad, it's saved as UTF-8.

If you *must* send inline JSON in CMD, escape every inner quote:
`-d "{\"title\":\"Dune\",\"author\":\"Frank Herbert\",\"year\":1965}"`

## GitHub 403 rate limit during `specify init`

`specify init` downloads templates from GitHub. Without authentication, GitHub allows only 60
requests/hour per IP. A whole lab on the same university network shares one IP.

Fix: create a GitHub personal access token (no scopes needed, a fine-grained token with
read-only public access is enough) at <https://github.com/settings/tokens> and pass it:

```cmd
specify init books-api --integration gemini --script ps --github-token YOUR_TOKEN
```

Or set it once: `setx GITHUB_TOKEN "YOUR_TOKEN"` (then reopen the terminal).

## `specify init` complains that `--integration` doesn't exist

You probably installed an old version or the unofficial PyPI package. Reinstall the pinned version:

```cmd
uv tool uninstall specify-cli
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.1.0
specify version
```

## `/speckit.*` commands don't appear in Gemini CLI

- Make sure you started `gemini` **inside the project folder** (`cd C:\dev\books-api` first).
- Check the folder `.gemini\commands\` exists. If not, re-run init in place:
  `specify init --here --integration gemini --script ps --force`
- Restart Gemini CLI (`/quit`, then `gemini`).

## Gemini CLI asks me to log in with Google / authentication errors

- Choose **"Use Gemini API key"**, not "Login with Google".
- Check the variable in a **new** terminal: `echo %GEMINI_API_KEY:~0,6%`
- If you also have `GOOGLE_API_KEY` set, Gemini CLI may use that one instead. Remove it if it's
  not intentional.
- Inside Gemini CLI, `/auth` lets you change the authentication method.
- 429 errors mean you hit your quota. Wait a minute and retry. Don't spam the same prompt.

## "running scripts is disabled on this system"

The agent tried to run a Spec Kit PowerShell script and execution policy blocked it:

```cmd
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"
```

If your machine is managed by the university and that fails, ask the instructor.

## `uv run uvicorn ...` fails with "No module named app" or "Could not import module"

The project structure the agent generated may differ. Check `specs/001-*/quickstart.md` or
`plan.md` for the exact run command, and make sure you're in the project root. If it's
inconsistent with the constitution (which says `app.main:app`), ask the agent to fix the
structure to match the constitution.

## Port 8000 is already in use

Another server is running (maybe a previous one you forgot). Close that terminal, or use another
port: `--port 8001` (and update your curl URLs).

## The agent is stuck, looping, or doing something I didn't ask

- Press **Esc** to interrupt it.
- Tell it precisely what's wrong and point it to the document: *"Task T012 in tasks.md says X,
  but you did Y. Redo T012 according to spec.md FR-004."*
- If the session got long and confused, `/quit` and start `gemini` again. The documents in
  `specs/` are its memory, so you don't lose your work.
