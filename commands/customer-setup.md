---
description: Set up a newly assigned or inherited customer account — detects whether history exists, researches the company, pulls Gong + Gmail history, finds the right Master Package, proposes the Customer page update + Active Package, and backfills all relevant post-sales sessions as Session records in Notion (existing customers only)
argument-hint: <customer name>
---

Set up account for.

Read the procedure in `agents/account-setup.md` and execute it inline as the main assistant — do not try to spawn `account-setup` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types).

## The procedure

1. **Locates the customer** in the Notion Customers DB and checks whether an Active Package already exists.

2. **Detects customer mode** after pulling Gong and Notion history:
   - **New customer** — no relevant post-sales sessions found. Creates the foundation only (Customer page + Active Package). No session backfill.
   - **Existing customer** — post-sales sessions found. Creates the foundation AND backfills all relevant sessions as Session records. Always backfills all — no partial backfills.

3. **Researches in parallel:**
   - Company overview via web search (industry, scale, geography, ownership)
   - Salesforce via Glean — plan, seat count, AE, AISE, renewal manager, health, billing cycle
   - Gong history — searches Glean with `app:gong` + customer name, then `read_document` on each call URL for full transcripts
   - Gmail history — `search_threads` with the customer domain, broader date range, including threads from previous AEs / predecessor AISEs
   - Notion — any existing sessions, tasks, or contacts already in the tracker

4. **Filters sessions** — only post-sales sessions are backfilled. Excluded: sales demos, discovery calls, pricing/negotiation calls, AE-only calls, internal PB syncs. When ambiguous, the agent flags the session for the user to decide.

5. **Maps the Master Package** from the Salesforce `servicesplan` field to the Master Packages DB.

6. **Proposes in chat (always — never writes without confirmation):**
   - Customer mode (new vs. existing)
   - Customer page update: company info, contacts, PB team
   - Active Package record: name, Master Package, dates (flagged if unknown), ARR (flagged if redacted), Status, Active?
   - Active Package page body: structured account history summary with Gong call summaries, email history, open items, workspace state
   - Session records to backfill (existing customer mode): one per relevant call, with date, inferred type (A/E/S), 2–3 sentence brief, and next steps agreed

7. **Writes on approval** in order: Customer page → Active Package → Session records. Reports all Notion URLs and flags remaining gaps.

## After setup

Once the Active Package is in place, run `/customer-plan-engagement [customer]` to build the program plan on top of it.
