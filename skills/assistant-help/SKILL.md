---
name: assistant-help
description: Quick reference of all available commands grouped by workflow stage, plus common patterns and links to deeper docs. Run anytime you forget what's available or want a refresher.
---

Output the help reference below verbatim, formatted as inline markdown in chat. Address the user by their `Display name` from `about/identity.md` if available; otherwise use a generic greeting.

---

# 🧭 Meeting Assistant — Quick Reference

Commands are grouped by family. Type `/<family>-` in autocomplete to see siblings.

## Common workflows (in order)

| Want to... | Run |
|---|---|
| **Get up to speed on a customer** before a meeting | `/customer-whats-new <customer>` |
| **Prepare for a customer session** | `/session-prep <customer> [session-type]` |
| **Run a full post-session debrief in one shot** | `/session-debrief <customer> [session-id]` |
| **Just summarize a delivered call** | `/session-summary [customer or session]` |
| **Draft a follow-up email** | `/draft-email <who/what>` (saves to Gmail Drafts, never sends) |
| **Plan the next phase of a customer's program** | `/customer-plan-next <customer>` (next 2-4 sessions) or `/customer-plan-engagement <customer>` (full program) |
| **Set up a brand-new or inherited account** | `/customer-setup <customer>` |
| **Score a delivered session against the rubric** | `/session-score <session-type>` |
| **Check Notion for data drift** | `/notion-check [--customer <name>] [--fix]` |
| **Answer a customer question with PB docs** | `/support-hub <query>` |
| **Sync Salesforce data into Active Packages** | `/notion-sync-sf [--customer <name>] [--apply]` |
| **Build a customer-facing diagram** | `/draft-diagram <customer> <type> [description]` |

## Notion writes

| Want to... | Run |
|---|---|
| **Create or update a Notion record** | `/notion-write <create\|update> ...` |
| **Generate a customer-facing KDD doc** for an architecting session (standalone) | `/session-kdds <customer> [session-id]` |

## Maintenance

| Want to... | Run |
|---|---|
| **Correct the assistant** (style nit, new rule, fact change) | `/assistant-remember <correction>` (invokes context-keeper) |
| **Automate a new recurring task** | `/assistant-automate <task description>` (drafts a new agent + command) |
| **(Re-)onboard yourself or a teammate** to this assistant | `/assistant-setup [--update \| --reset \| --scrape-voice]` |
| **This help reference** | `/assistant-help` |

## Suggested order around a customer session

1. **Day before:** `/customer-whats-new <customer>` — surface what's changed since the last touch.
2. **Day before / morning of:** `/session-prep <customer>` — pulls context, drafts brief, lands in Notion under a `📋 Prep` toggle. For architecting sessions, also creates a customer-facing KDD sub-page.
3. **Same day after the call:** `/session-debrief <customer>` — runs summary + Notion updates + Tasks + Gmail follow-up draft + Slack debrief draft + scorecard eval, all in one go.
4. **Optional:** `/session-score <session-type>` if you want a focused scorecard review.

## Command families at a glance

- **`customer-*`** — customer/account lifecycle (`-setup`, `-whats-new`, `-plan-next`, `-plan-engagement`)
- **`session-*`** — work tied to a specific session (`-prep`, `-kdds`, `-summary`, `-score`, `-debrief`)
- **`draft-*`** — message / artifact drafts (`-email`, `-followup`, `-diagram`)
- **`notion-*`** — direct Notion operations (`-write`, `-check`, `-sync-sf`)
- **`assistant-*`** — meta / configure the assistant (`-setup`, `-help`, `-remember`, `-automate`)
- **Standalone** — `/support-hub`

## Personal config

Your identity, voice preferences, and workspace specifics live in `about/`:

- `about/identity.md` — name, Notion user ID, role, time zone
- `about/voice.md` — sign-offs, language quirks, casual register
- `about/workspace.md` — Slack patterns, Calendly URLs, internal coordinators

To change them: edit directly, or run `/assistant-setup --update` for a guided drift check.

## Where things live

| Where | What |
|---|---|
| **Notion** | Source of truth for active engagements, per-customer state, sessions, tasks, working notes |
| **`context/notion-schema.md`** | DB schema, field formats, query patterns |
| **`context/score-cards.md`** | Per-session scorecards (Discovery, Foundations, Insights, Prioritization, Roadmaps, Spark, Success Planning, QBR) |
| **`context/pb-aise-reference-guide.md`** | Session methodology — "what good looks like" per session type |
| **`context/communication-style-guide.md`** | Universal AISE comms patterns; `about/voice.md` overrides |
| **`templates/session-kdds/`** | Customer-facing KDD anchor templates per A-session type |
| **`<PLUGIN_DATA_DIR>/about/tracker-memory.md`** | Cross-customer observations only — per-user, written by `context-keeper` (Notion is SSOT for everything else) |

## Tips

- **Don't paste context** the assistant can retrieve. Just name the customer or session — agents pull from Glean, Gmail, Calendar, Notion, Slack automatically.
- **Confirm before destructive writes.** Notion updates ask before applying unless explicitly told otherwise.
- **Customer-side actions don't go in the Tasks DB.** Only PB-side actions assigned to you. Customer commitments live in summaries / follow-ups.
- **Internal tasks** (no specific customer) point at the **Productboard** customer record automatically.

For full details on any command, see ``commands/<command-name>.md``. Agent specs are in `agents/`.
