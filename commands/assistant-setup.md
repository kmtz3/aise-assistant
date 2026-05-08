---
description: Onboard a new user (or re-onboard yourself) to this assistant. Resolves Notion identity, asks short HITL questions about voice + workspace preferences, optionally scrapes recent Gmail and Slack to draft your voice profile, and writes the about/ folder. Run on first install of the plugin or when handing the assistant off to a teammate.
argument-hint: "[--scrape-voice] [--reset]"
---

Set up the assistant for the current user.

Read the procedure in `agents/assistant-onboarding.md` and execute it inline as the main assistant — do not try to spawn `assistant-onboarding` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. Detect the Notion connection and resolve the current user via `notion-get-users self` → auto-fills `about/identity.md` with the Notion user ID.
2. Ask HITL questions covering identity, voice, and workspace preferences in **one combined elicitation form**. Reserve `AskUserQuestion` only for a single ad-hoc clarification that arises after the form is submitted.
3. Optionally (`--scrape-voice` or when the user opts in via the form): read 5–10 recent sent emails from Gmail and 5–10 recent Slack messages, distinguishing **internal** vs **client-facing** tone, and draft a `voice.md` from the user's actual writing style.
4. **Write files directly to `about/`** (`about/identity.md`, `about/voice.md`, `about/workspace.md`). Present `computer://` links to each written file so the user can open them.
5. Confirm setup in chat. Note that these files live only on this machine — on a new machine, run `/assistant-setup` again.

**Modes (mutually exclusive):**
- **Default** (no flag) — fill gaps only. Preserves existing `about/` values; asks only about fields still set to `<TBD>`. Safe to re-run whenever.
- **`--update`** — drift check. Re-resolves Notion identity (catches user ID changes, role changes), then walks each section asking the user to confirm or update values that may have drifted.
- **`--reset`** — wipe everything. Deletes `about/identity.md`, `about/voice.md`, `about/workspace.md`, restores them from `about/templates/*.md.template`, and runs the full onboarding flow from scratch.

**Modifier flag (combinable with any mode):**
- **`--scrape-voice`** — skip the opt-in question and go straight to Gmail+Slack scraping for the voice draft.

**Don't ask the user for values that are retrievable.** Notion user ID, primary email, time zone — pull from the connected account, don't ask.
