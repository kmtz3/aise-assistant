---
description: Build a full program plan (goals, milestones, phases, sessions) for a newly assigned customer — lands in the Active Package page in Notion
argument-hint: <customer>
---

Build the engagement program plan for.

Read the procedure in `agents/engagement-planner.md` and execute it inline as the main assistant — do not try to spawn `engagement-planner` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. **Locate the customer in Notion.** Customer page + Active Package + Master Package (contracted allocation) + Contacts + any existing Sessions. Pull the Active Package URL — that's where the plan will land.
2. **Pull context in parallel** — Glean (Slack / Salesforce / Gong / Drive / Confluence for this customer), Gmail threads (AE handoff, kickoff coordination), Calendar (upcoming sessions already booked), past chats, the 🧠 Working Notes toggle on the customer's Active Package page in Notion.
3. **Confirm scope inputs** (customer-side program owner, exec sponsor, pilot team, target timeline, key pain points, known blockers). If any can't be retrieved, ask once as a single consolidated question — do not ask for anything retrievable.
4. **Apply `context/engagement-planning-guide.md`** — goals → milestones → phases → sessions → parallel streams. Enforce A / E / S naming conventions and the quality-check list.
5. **Cross-check against standards** — scorecard principles (`context/score-cards.md`) and the phase map + common risks in `context/pb-aise-reference-guide.md`.
6. **Draft the plan in chat** using the output-format template from the guide. Iterate with the user before writing to Notion.
7. **On approval, post to Notion** following the `agents/notion-writer.md` procedure (read and run inline):
   - Append a collapsible toggle heading `🗺️ Program Plan — YYYY-MM-DD` to the **Active Package page body** (not the Customer page).
   - Optionally create `Call Status = Planned` Session records for each session in Phase 1, linked to the Customer and `Consumed Package = [Active Package]`.
   - Only create Tasks for PB-side action items (the user's work), never customer-side.

Do NOT invent stakeholder names, dates, or commitments. Flag gaps. Flag conflicts between sources rather than silently picking.
