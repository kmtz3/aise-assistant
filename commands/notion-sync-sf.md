---
description: Sync Salesforce ARR and contract end dates into Notion Active Packages — fills null ARRs, corrects stale end dates, handles renewal rollovers (deactivate old + create new), flags churned/at-risk accounts for review.
argument-hint: "[--customer <name>] [--owner <name>] [--apply]"
---

Run a Salesforce → Notion backfill for active packages.

Read the procedure in `agents/sf-backfill.md` and execute it inline as the main assistant — do not try to spawn `sf-backfill` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. Query all Active Packages where `Active? = YES` (or one customer if `--customer <name>` is provided).
2. For each customer, query Salesforce directly via SOQL (open renewal opps + recent closed opps) and extract: ARR (ACV from opp Amount — never divided by term) and contract end date (ContractStartDate of open renewal opp, falling back to CloseDate of last Closed Won — never the auto-generated renewal opp CloseDate).
3. Classify each account: rollover needed / ARR fill / end-date update / already in sync / skip (no SF opp) / flag (churned or at-risk).
4. Present the full proposed change list and wait for approval before writing — unless `--apply` is passed, in which case it writes immediately then reports.
5. Apply approved changes: update existing packages and/or deactivate old + create new Active Packages for rollovers.

**Flags:**
- `--customer <name>` — run for a single customer instead of all active packages
- `--apply` — skip the approval gate and write directly

Do NOT ask the user for Salesforce data — query Salesforce directly via the SF MCP. Do NOT touch churned or at-risk accounts.
