---
description: Documentation update — scans actual agents/, skills/, commands/ and context/ state, identifies drift vs README.md, CLAUDE.md, and DEVELOPMENT.md, then proposes and applies targeted edits.
---

Audit and update the aise-assistant documentation. Follow these steps exactly.

## Step 1 — Snapshot the actual project state

Run these in parallel to get the ground-truth roster:

```bash
# Agents
ls agents/*.md | xargs -I{} basename {} .md | sort

# Skills (each is a directory with a SKILL.md inside)
ls skills/ | sort

# Local slash commands (.claude/commands/)
ls .claude/commands/*.md | xargs -I{} basename {} .md | sort

# Context files
ls context/*.md | xargs -I{} basename {} .md | sort
```

Also read the frontmatter `name:` and `description:` from each agent file:
```bash
grep -h "^name:\|^description:" agents/*.md | paste - -
```

And the skill descriptions:
```bash
for d in skills/*/; do echo "$(basename $d): $(grep '^description:' "$d/SKILL.md" | head -1 | sed 's/description: //')"; done
```

Record: agent count, skill count, exact names, descriptions.

## Step 2 — Read the current docs

Read all three docs in parallel:
- `README.md`
- `CLAUDE.md`
- `DEVELOPMENT.md`

## Step 3 — Identify drift

Check each of the following and flag every discrepancy:

### README.md
- **Command count** — "N slash commands" in the intro. Does it match `ls skills/ | wc -l`?
- **Agent count** — "N specialist agents". Does it match `ls agents/*.md | wc -l`?
- **Command families** — each family block (`customer-*`, `session-*`, `draft-*`, `notion-*`, `assistant-*`, Standalone). Are all skills listed? Are any removed ones still listed? Are counts in parentheses correct?
- **Workflow shape table** — does it reference any commands that no longer exist? Are new commands missing?

### CLAUDE.md
- **Slash commands table** — one row per skill. Is every skill in `skills/` represented? Are any deleted skills still listed? Are descriptions stale vs the skill's frontmatter `description:`?
- **Agents table** — one row per agent. Is every agent in `agents/` represented? Are any removed agents still listed? Are descriptions stale?
- **Local .claude/commands table** (if present) — does it list `/commit` and `/update-docs`? Add a table if commands exist and none is documented.

### DEVELOPMENT.md
- **Versioning section** — no structural drift check needed here beyond the dual-file rule (already documented). Flag only if a version file is referenced that no longer exists.
- **What gets packaged vs excluded table** — does it still accurately reflect the directory structure? (e.g. if a new top-level dir was added, it should appear here)

## Step 4 — Propose updates

Print a diff summary grouped by file:

```
## Documentation drift report — {date}

### README.md
- [list each drift item with proposed fix]

### CLAUDE.md
- [list each drift item with proposed fix]

### DEVELOPMENT.md
- [list each drift item with proposed fix]

### No changes needed
- [list any file that is already accurate]
```

If there is NO drift in a file, say "✓ accurate — no changes" for that file.

Ask: **"Apply all proposed changes?"** Wait for confirmation before writing.

## Step 5 — Apply approved updates

For each approved change, use the Edit tool to make targeted replacements. Do not rewrite whole files — patch only the drifted sections.

After all edits, run:
```bash
git diff --stat
```

Report what changed.

## Step 6 — Offer to commit

Ask: "Commit these doc updates?" If yes, invoke `/commit` (it will classify the changes as PATCH and handle both version files).
