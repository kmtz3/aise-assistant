---
name: bulk-prep-week
description: Scan the upcoming week's calendar, identify all external customer sessions, and run session prep for each — deduplicates against existing Notion Session pages rather than creating duplicates.
---

Run bulk session prep for all external customer sessions in the upcoming week: **$ARGUMENTS**

Read the procedure in `agents/bulk-prep-week.md` and execute it inline as the main assistant — do not try to spawn `bulk-prep-week` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. Resolve the time window — default today + 7 days; `--week YYYY-MM-DD` anchors to a specific Monday–Sunday.
2. Pull all external calendar events — filter out all-PB meetings, declines, sub-30-min events, and all-day blockers.
3. Map each event to an owned Notion Customer record (by attendee domain / title); log unmatched and ambiguous as ⚠️.
4. Dedup: skip sessions that already have a `📋 Prep` toggle; update existing session pages that don't; create pages for sessions with no Notion record yet.
5. Run full session prep (following `session-prepper.md`) sequentially for each session that needs it — including KDD sub-pages for any Architecting sessions.
6. Report a per-session status table with links to all prepped Notion pages and a count of skipped / flagged items.

Do NOT ask the user for context that's retrievable. Search first, ask once if something is genuinely missing.
