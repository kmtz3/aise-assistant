# Changelog

All notable changes to aise-assistant are documented here.
Format: `## [version] — YYYY-MM-DD` followed by bullet points grouped by type.

---

## [2.2.2] — 2026-05-09

### Changed
- Extract identity resolution into a canonical procedure in `context/notion-schema.md` § Identity resolution (three-path chain + graceful stop + `--global` skip rule)
- `notion-flag-renewals` and `notion-sync-owner` Step 1 now reference the shared procedure instead of inlining it

---

## [2.2.1] — 2026-05-09

### Fixed
- `notion-flag-renewals`: identity resolution is now conditional — `--global` skips Step 1 entirely (no file lookup)
- `notion-flag-renewals`: graceful fallback for `--mine` when `.datadir` or `notion_user_id` is missing — surfaces a clear inline message instead of a broken query
- `notion-flag-renewals`: three-path identity resolution (`.datadir` → glob plugin dirs → `notion-get-users` + userEmail)
- `notion-flag-renewals`: date and status filtering pushed into the SQL query — collapses 3 paginated round-trips into 1 targeted fetch
- `notion-flag-renewals`: document known macOS plugin data dir paths directly in the skill

---

## [2.2.0] — 2026-05-09

### Added
- `/notion-sync-owner` skill — push `Customer.Owner` → `Current Account Owner` on all linked Sessions, Tasks, and Active Packages (`--mine` / `--global`)
- `/notion-flag-renewals` skill — set `Status = Renewal` on active packages ending within N days; `--dry-run` previews without writing

---

## [2.1.0] — 2026-05-09

### Added
- Customer page template with agent-readable sections (notion-schema.md)
- Active Package template wired into account-setup and notion-writer agents

### Fixed
- Scope Gong queries to post-sales calls; skip Gmail lookups in delegated (teammate) mode
- Session page structure now driven from Notion templates rather than hard-coded agent logic

---

## [2.0.0] — 2026-05-09

### Added
- `customer-plan-next` agent and `/customer-plan-next` command
- Session page structure driven from Notion templates

### Fixed
- Full plugin review fixes; gitignore `.claude/` from distribution

---

## [1.2.3] — 2026-05-08

### Fixed
- Resolve persistent plugin data dir via pointer file — never use `$CLAUDE_PLUGIN_DATA`

---

## [1.2.2] — 2026-05-08

### Changed
- Unify transcript lookup logic into a single canonical source across session-summarizer and post-session-debrief

---

## [1.0.1] — 2026-05-08

### Changed
- Revise versioning rules — MAJOR for any capability roster change, MINOR for functional tweaks

---

## [1.0.0] — 2026-05-08

### Added
- Initial release of aise-assistant plugin
- Marketplace metadata (`marketplace.json`) and auto version-bump on package
- Full agent roster: session-prepper, session-summarizer, post-session-debrief, engagement-planner, account-setup, email-drafter, kdd-builder, notion-writer, context-keeper, diagram-builder, sf-backfill, support-hub, notion-integrity-check, whats-new, assistant-onboarding, bulk-debrief, bulk-prep-week, bulk-account-setup, daily-brief, customer-plan-next, workflow-advisor
- Slash command families: `customer-*`, `session-*`, `draft-*`, `notion-*`, `assistant-*`
