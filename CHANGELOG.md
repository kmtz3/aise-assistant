# Changelog

All notable changes to aise-assistant are documented here.
Format: `## [version] — YYYY-MM-DD` followed by bullet points grouped by type.

---

## [2.3.0] — 2026-05-09

### Changed
- Consolidated 7 skills into 3 multi-mode commands to reduce surface area as the plugin grows
- `notion-sync-sf` + `notion-sync-owner` + `notion-flag-renewals` → `/notion-sync --sf|--owner|--renewals` (all push external data into Notion; share `--mine`, `--global`, `--dry-run`, `--no-confirm` flag conventions)
- `bulk-debrief-yesterday` + `bulk-prep-week` → `/bulk --debrief|--prep` (both run a session workflow in bulk across calendar events)
- `customer-plan-next` + `customer-plan-engagement` → `/customer-plan --next|--full` (both plan forward; flag is just scope)
- `skills/assistant-help/SKILL.md`: rewritten with new command names, per-command flag reference tables, and usage examples for all multi-mode commands
- All agent files, context files, and templates updated: `agents/account-setup.md`, `agents/bulk-account-setup.md`, `agents/engagement-planner.md`, `agents/assistant-onboarding.md`, `context/engagement-planning-guide.md`, `templates/session-kdds/00-index.md`, `skills/customer-setup/SKILL.md`
- `CLAUDE.md` command registry updated: new `bulk` family section added; `notion-*` table updated; `customer-plan` rows updated; agent table gains `customer-plan-next` row; output defaults updated
- `README.md` updated: command count 25 → 22, family listings, workflow table

---

## [2.2.5] — 2026-05-09

### Changed
- `notion-schema.md` + `agents/notion-writer.md`: Tasks created after a session must now set `Consumed Package` — inherit from `Source Call` if present, otherwise apply the same date-matching logic as Sessions (active package covering today → most-recently-ended inactive package → leave empty)

---

## [2.2.4] — 2026-05-09

### Fixed
- `session-summarizer` / `project-instructions.md`: Glean `read_document` step now extracts the `id` field from search result objects instead of passing a URL string (which the tool rejects)
- `account-setup`: same `read_document` fix in Step 2 (Gong transcripts) and Guardrails
- `post-session-debrief` Step 12: Customer page update now fetches the page first, checks for template headings before writing, and falls back to appending a `## 📋 Account Notes` section on pages with non-standard templates instead of erroring
- Remove all references to `## 🤝 PB Account Team` — section deleted from the Customer page template; `notion-schema.md` table updated (five → four sections), `account-setup` Step 4A and Step 5 updated accordingly; AE/Renewal Manager info redirected to page properties

---

## [2.2.3] — 2026-05-09

### Fixed
- `notion-sync-owner`: accept `--me` as an alias for `--mine` in Step 2 and Flags section
- `notion-sync-owner`: Customers/Customer relation fields store hyphen-stripped Notion page URLs — LIKE pattern now uses `<customer-url-id>` (hyphens removed), not the bare UUID
- `notion-sync-owner`: drift filter (`Current Account Owner NOT LIKE '%<owner-uuid>%' OR IS NULL`) moved directly into Step 4 WHERE clauses; removed separate Step 5 drift-detection pass to avoid hitting the 500-row LIMIT on already-correct records
- `notion-sync-owner`: Step 1 now documents a fallback to `notion-get-users` with the user's email when `identity.md` is not found, preventing a hard-fail on fresh installs

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
