---
description: Evaluate a described task for automation and, on approval, create the agent + slash command + CLAUDE.md entries for it
argument-hint: <describe the task or workflow>
---

the user wants to evaluate automating.

Read the procedure in [`.claude/agents/workflow-advisor.md`](.claude/agents/workflow-advisor.md) and execute it inline as the main assistant — do not try to spawn `workflow-advisor` as a subagent (custom agents in this plugin are procedure documents, not registered subagent types). The steps:

1. Check whether a command/agent already covers this task  –  stop and redirect if so.
2. Assess whether it clears the automation bar (recurring, repeatable, >5 min or error-prone).
3. Draft the new `agents/<name>.md`, `commands/<name>.md`, and the CLAUDE.md table rows.
4. Present the full proposal in chat with estimated time savings and a preview of all new content.
5. Wait for approval, then write the files and confirm.

Do NOT write any files until the user approves the proposal.
