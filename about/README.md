# `about/` — Per-user profile

This folder holds **everything specific to the user running this assistant**. The rest of the assistant (agents, commands, schemas, templates, methodology) is universal — anyone in the same role can use it as-is.

The plugin ships with placeholder content here. Run `/assistant-setup` to populate it for yourself, or for a teammate who's onboarding.

## Files

| File | Holds |
|---|---|
| [`identity.md`](identity.md) | Name (incl. accent variants to strip), email, Notion user ID, role, team, time zone |
| [`voice.md`](voice.md) | Personal communication style: sign-offs, formatting quirks, language rules, casual register |
| [`workspace.md`](workspace.md) | Workspace specifics: Slack channels, internal coordinators, conferencing prefs, AE/AISE relationships |

Universal communication methodology (PB-AISE comms patterns, customer-vs-internal tone, structure templates) lives in [`context/communication-style-guide.md`](../context/communication-style-guide.md). Your `voice.md` overlays personal preferences on top.

## How agents use these files

Every agent that needs a personal value (e.g. your Notion user ID for filtering queries) reads `about/identity.md` at the start of its run. Don't hardcode personal values in agent specs — always reference these files.

For voice/style decisions, agents read `about/voice.md` alongside `context/communication-style-guide.md` and treat `voice.md` as the override.

## Populating this folder

**First time?** Run `/assistant-setup`. It'll:
1. Auto-resolve your Notion user ID via the connector.
2. Ask you a short series of questions about identity, voice preferences, and workspace.
3. Optionally scrape recent Gmail and Slack to draft your `voice.md` from how you actually write (distinguishing internal vs client-facing tone).
4. Write all three files directly to `about/` with your real values, replacing the `<TBD>` placeholders — no manual file copy needed.

**Modes:**
- **Default** (no flag) — fill gaps only. Preserves existing values, only asks about fields still set to `<TBD>`.
- **`--update`** — drift check. Re-resolves Notion identity (catches user ID changes, role changes), surfaces any fields that look stale or that the assistant has been corrected on, asks you to confirm or update each one.
- **`--reset`** — wipe everything. Deletes `about/identity.md`, `about/voice.md`, `about/workspace.md`, restores them from `about/templates/*.md.template`, and re-runs the full onboarding flow from scratch. Use when handing off the assistant to a teammate, or starting clean after a major role/preference shift.
- **`--scrape-voice`** — skip the opt-in question and go straight to Gmail+Slack scraping for the voice draft.

**Continuous updates.** The `context-keeper` agent also proposes updates here whenever you correct it on a personal preference (style nit, sign-off change, voice rule).

## Templates

The `about/templates/` subfolder holds the placeholder versions that ship with the plugin (`identity.md.template`, `voice.md.template`, `workspace.md.template`). Don't edit these unless you're changing the plugin's onboarding scaffold for everyone. Edit your own `about/identity.md`, `about/voice.md`, `about/workspace.md` directly (or via `/assistant-setup`).

## Upgrade preservation

When a new plugin version is installed, personal files are **preserved** if they have been populated — i.e., they exist and contain no `<TBD` placeholder anywhere. Files that still have `<TBD` are treated as unpopulated and overwritten with the new template.

`about/README.md` and `about/templates/` are always replaced (plugin-owned). Your `identity.md`, `voice.md`, and `workspace.md` are never overwritten once populated.

To upgrade safely via the shell: `./scripts/upgrade.sh --source <path-to-new-version>`

If your personal files were preserved after an upgrade, run `/assistant-setup --update` to check for any drift (new fields, role changes, updated preferences).

## Privacy note

These files contain personal info. They should NOT be committed to a shared plugin repo or shipped to teammates. The plugin export process strips this folder and ships with empty placeholder templates instead.
