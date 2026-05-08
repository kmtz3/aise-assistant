---
name: assistant-setup
description: Onboard a new user (or re-onboard yourself) to this assistant. Resolves Notion identity, asks short HITL questions about voice + workspace preferences, optionally scrapes recent Gmail and Slack to draft your voice profile, and writes the about/ folder. Run on first install of the plugin or when handing the assistant off to a teammate.
---

Set up the assistant for the current user.

Read the procedure in `agents/assistant-onboarding.md` and execute it inline as the main assistant — do not try to spawn `assistant-onboarding` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

0. **Run the connection check first.** Before anything else, run `./scripts/setup-connections.sh --check` via `mcp__Control_your_Mac__osascript` (file and bash tools are sandboxed in Cowork and cannot reach the plugin directory). Surface the full output in chat. If `sf-mcp-server` is missing, tell the user to install it. Do not skip this step.
1. Detect the Notion connection and resolve the current user via `notion-get-users self` → auto-fills `about/identity.md` with the Notion user ID.
2. Ask HITL questions covering identity, voice, and workspace preferences in **one combined elicitation form** (call `read_me` with `modules: ["elicitation"]` first, then render a single card — no sequential question-by-question flow). Reserve `AskUserQuestion` only for a single ad-hoc clarification that arises after the form is submitted.
3. Optionally (`--scrape-voice` or when the user opts in via the form): read 5–10 recent sent emails from Gmail and 5–10 recent Slack messages, distinguishing **internal** vs **client-facing** tone, and draft a `voice.md` from the user's actual writing style. For Slack, read the `slack_search_public_and_private` tool description to find the `Current logged in user's user_id is <ID>` line — use `from:<@USER_ID>` as the query (not the email address).
4. **Write files directly to `about/`** (`about/identity.md`, `about/voice.md`, `about/workspace.md`). Present `computer://` links to each written file so the user can open them.
5. Confirm setup in chat. Note that these files live only on this machine — on a new machine, run `/assistant-setup` again.

**Modes (mutually exclusive):**
- **Default** (no flag) — fill gaps only. Preserves existing `about/` values; asks only about fields still set to `<TBD>`. Safe to re-run whenever.
- **`--update`** — drift check. Re-resolves Notion identity (catches user ID changes, role changes), then walks each section asking the user to confirm or update values that may have drifted. Useful after a role change, team move, or workflow shift.
- **`--reset`** — wipe everything. Deletes `about/identity.md`, `about/voice.md`, `about/workspace.md`, restores them from `about/templates/*.md.template`, and runs the full onboarding flow from scratch. Use when handing the assistant off to a teammate, or starting clean after a major shift.

**Modifier flag (combinable with any mode):**
- **`--scrape-voice`** — skip the opt-in question and go straight to Gmail+Slack scraping for the voice draft. Distinguishes internal vs client-facing tone.

**Don't ask the user for values that are retrievable.** Notion user ID, primary email, time zone — pull from the connected account, don't ask. Reserve HITL questions for genuine preferences (sign-offs, em-dash rule, Slack register, etc.).

Save scraped raw email/Slack samples to a temp file the user can reference if they want to tweak the inferred voice.md by hand.

## Cowork: writing about/ files

In Cowork mode, `Write`, `Edit`, and `mcp__workspace__bash` are sandboxed to the session outputs folder and cannot reach the plugin directory. Use `mcp__Control_your_Mac__osascript` to write `about/identity.md`, `about/voice.md`, and `about/workspace.md`.

**Pattern: Python script via heredoc**

1. **Resolve the plugin root** from the system prompt. File paths in system-reminder tags reveal the plugin location -- look for `rpm/plugin_*/` to find the `about/` directory.

2. **Write all three files in one osascript call.** The pattern:
   - `do shell script` wraps a bash heredoc using `<< 'PYEOF'` (single-quoted delimiter -- passes content through literally with no substitution)
   - Python writes each file using `pathlib.Path(...).write_text(content, encoding='utf-8')`
   - File content goes in Python triple-single-quoted strings, which handle apostrophes and backticks without restriction

3. **Critical constraint:** The outer `do shell script` command is an AppleScript string delimited by double quotes. Any double-quote character anywhere inside the heredoc content will terminate this outer string early and cause a syntax error. Keep all file content free of double-quote characters. If a double-quote is unavoidable, use the Python hex escape sequence for ASCII 0x22 in the Python source.

4. **Verify after writing.** Call `Read` on each `about/` file path to confirm content landed correctly before reporting success to the user.
