---
description: Draft an email and save it as a Gmail draft (never sends — always drafts for review)
argument-hint: <who it's for / what it's about>
---

Draft email(s) for.

Read the procedure in `agents/email-drafter.md` and execute it inline as the main assistant — do not try to spawn `email-drafter` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The procedure pulls context across Glean / Notion / Gmail / Calendar / past chats so the draft is grounded in the actual session history, outstanding tasks, and prior commitments — not a generic sales-toned outreach.

## Hard rule — NEVER SEND

The drafted email is **always** saved to Gmail Drafts. Under no circumstance should the email be sent. No send tool. No "should I send?" question. Drafts folder, review, done.

## What the procedure must do

1. **Identify the source material** — which customer, which session / thread / task this email references, who the recipient is. Never guess recipients — look them up in the Notion Contacts relation or a recent Gmail thread.

2. **Pull context across connectors in parallel:**
   - **Notion** — customer page, most recent Sessions, open Tasks (PB-side and customer-side), specific session page being referenced.
   - **Gmail** — recent threads with the recipient; the specific thread if this is a reply.
   - **Glean** — `gmail_search` for adjacent stakeholders, `search`/`chat` for Slack/Salesforce/Gong.
   - **Calendar** — confirm meeting date/time anchors.

3. **Draft in the user's voice (per `about/voice.md`)** per `context/communication-style-guide.md`. Warm + direct, bold labels over headers, bullets for lists. For ongoing architecting / working cadence: reference *what we agreed* + *what's next* + the ask.

4. **Don't invent** — dates, commitments, scope, names. If something load-bearing is missing, flag as `[FILL IN: ...]`.

5. **Save as Gmail draft** with `create_draft` (both `body` and `htmlBody`). Return the draft ID.

6. **Report back in chat** for each draft: draft ID, recipient, subject, cc, one-line angle, `[FILL IN]` placeholders, full body inline.

## What NOT to include

- Internal-only context (commercial stance, credit/renewal detail) unless explicitly asked.
- Speculation presented as fact.
- Sales-toned filler ("circling back", "touching base", "reach out to see if").
