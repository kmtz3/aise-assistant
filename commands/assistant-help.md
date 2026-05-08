---
description: Quick reference of all available commands grouped by workflow stage, plus common patterns and links to deeper docs. Run anytime you forget what's available or want a refresher.
argument-hint: ""
---

Generate a help reference for the user. The command tables must be built dynamically — do not use a hardcoded list.

**Steps:**

1. Read `about/identity.md`. Extract the user's first name for the greeting (skip the name if the file still has `<TBD` values).

2. Read `CLAUDE.md`. Extract the full `## Slash commands` section — everything from that heading down to the next `---` divider. This is the authoritative, always-current list of commands grouped by family. Render each sub-section and table verbatim.

3. List all files in `commands/`. For any `.md` file whose base name does not appear as a command in the CLAUDE.md slash commands section, append it at the end under a `### Other` sub-section so nothing is silently invisible.

4. Render the output in chat using the template below. Substitute the dynamic command tables from steps 2–3 where indicated. The rest of the template is static — output it as-is.

---

# 🧭 AISE Assistant — Quick Reference

Hey [first name] — here's everything available.

## Commands

[INSERT the full ## Slash commands section extracted from CLAUDE.md here, preserving all sub-section headings and tables. If step 3 found any unlisted command files, append them under ### Other.]

---

## Suggested order around a customer session

0. **Morning of:** `/daily-brief [--open]` — today's schedule + open tasks + tomorrow's sessions flagged, prep blocks auto-created on your calendar.
1. **Day before:** `/customer-whats-new <customer>` — surface what's changed since the last touch.
2. **Day before / morning of:** `/session-prep <customer>` — pulls context, drafts brief, lands in Notion under a `📋 Prep` toggle. For architecting sessions, also creates a customer-facing KDD sub-page.
3. **Morning of (bulk):** `/bulk-prep-week` — runs prep for every external session in the upcoming week in one go.
4. **After the call:** `/session-debrief <customer>` — summary + Notion updates + Tasks + Gmail follow-up draft + Slack debrief draft + scorecard eval, all in one shot.
5. **End of day (bulk):** `/bulk-debrief-yesterday` — runs full debriefs for all external meetings from the previous day.

---

## Personal config

Your identity, voice preferences, and workspace specifics live in `about/`:

- `about/identity.md` — name, Notion user ID, role, time zone
- `about/voice.md` — sign-offs, language quirks, casual register
- `about/workspace.md` — Slack patterns, Calendly URLs, internal coordinators

To change them: edit directly, or run `/assistant-setup --update` for a guided drift check.

---

## Where things live

| Where | What |
|---|---|
| **Notion** | Source of truth for active engagements, per-customer state, sessions, tasks, working notes |
| **`context/notion-schema.md`** | DB schema, field formats, query patterns |
| **`context/score-cards.md`** | Per-session scorecards (Discovery, Foundations, Insights, Prioritization, Roadmaps, Spark, Success Planning, QBR) |
| **`context/pb-aise-reference-guide.md`** | Session methodology — "what good looks like" per session type |
| **`context/communication-style-guide.md`** | Universal AISE comms patterns; `about/voice.md` overrides |
| **`templates/session-kdds/`** | Customer-facing KDD anchor templates per A-session type |
| **`context/tracker-memory.md`** | Cross-customer observations only (Notion is SSOT for everything else) |

---

## Tips

- **Don't paste context** the assistant can retrieve. Just name the customer or session — agents pull from Glean, Gmail, Calendar, Notion, Slack automatically.
- **Confirm before destructive writes.** Notion updates ask before applying unless explicitly told otherwise.
- **Customer-side actions don't go in the Tasks DB.** Only PB-side actions assigned to you. Customer commitments live in summaries / follow-ups.
- **Internal tasks** (no specific customer) point at the **Productboard** customer record automatically.

For full details on any command, see `commands/<command-name>.md`. Agent specs are in `agents/`.
