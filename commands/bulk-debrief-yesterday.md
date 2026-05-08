---
description: Run the full post-session debrief for every external customer meeting from the previous calendar day — discovers from Calendar, matches to Notion customers + sessions, checks for prior debrief signals, and executes all fresh or partial debriefs sequentially.
argument-hint: "[--date YYYY-MM-DD] [--skip <customer>] [--rerun <customer>]"
---

Run the full post-session debrief workflow for all external customer meetings from yesterday (or a specified date).

Read the procedure in `agents/bulk-debrief.md` and execute it inline as the main assistant — do not try to spawn `bulk-debrief` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. Determine the target date (yesterday by default; `--date YYYY-MM-DD` to override). Pull all calendar events and filter to external-confirmed meetings (≥1 non-@productboard.com attendee, user accepted, event confirmed).
2. Match each external meeting to a Notion Customer record (Owner-filtered to the current user) and existing Session record. Run a pre-flight debrief state check per session: notes exist? Gmail draft exists? Tasks exist? Flag fully-debriefed sessions as skipped, partially-debriefed as "fill gaps only."
3. Present the debrief queue — sessions queued with debrief state, sessions likely already debriefed (skipped by default, use `--rerun <customer>` in your reply to force-include), sessions skipped for other reasons, and anything needing user input. Wait for one go-ahead.
4. Execute the full `post-session-debrief` procedure inline for each queued session, sequentially in chronological order. Pass a bulk-run flag so dedup defaults inside that agent fall to "skip" rather than interrupting for input.
5. Print a master summary: sessions debriefed (with dedup skips noted per session), sessions already debriefed and skipped, other skips, and anything needing manual follow-up.

Do NOT start running debriefs before the step 3 confirmation. Do NOT run debriefs in parallel.
