---
description: Commit Skill — aise-assistant version. Classifies changes, bumps version in both package.json and .claude-plugin/plugin.json (semver), then commits all modified files.
---

Commit the current changes for aise-assistant. Follow these steps exactly.

## Step 1 — Understand the changes

Run in parallel:
```bash
git status
git diff HEAD
git log --oneline -5
```

Review the diff to understand what changed.

## Step 2 — Determine the semver bump

Use the rules from DEVELOPMENT.md:

| Change type | Bump |
|---|---|
| Skill, command, or agent **added or deleted** (capability roster changes) | MAJOR — `X+1.0.0` |
| Functional tweak to an existing capability (new behavior within a skill/agent) | MINOR — `X.Y+1.0` |
| Bug fix or behavior correction, no new functionality | PATCH — `X.Y.Z+1` |

- MAJOR auto-wins — if the diff shows a skill/command/agent added or removed, always bump MAJOR.
- A single commit can only bump one level. If it includes both new capabilities and fixes, take the higher level.
- Never skip versions — increment by 1 only.
- PATCH resets to 0 on MINOR bump. MINOR and PATCH reset to 0 on MAJOR bump.

Read the current version:
```bash
node -p "require('./package.json').version"
```

## Step 3 — Bump the version in BOTH files

**Version lives in two places — both must be updated:**
- `package.json` → `"version"`
- `.claude-plugin/plugin.json` → `"version"`

Edit both files using the Edit tool (not sed or shell substitution).

## Step 4 — Stage and commit

Stage the changed files plus both version files:
```bash
git add <files> package.json .claude-plugin/plugin.json
```

Never use `git add -A` or `git add .` — add files by name only.

Write the commit message using a HEREDOC:
```bash
git commit -m "$(cat <<'EOF'
<type>: <description> (vX.Y.Z)

<optional body — what changed and why>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

## Step 5 — Push

```bash
git push
```

## Step 6 — Confirm

Run `git status` to confirm the working tree is clean, then report what was committed, the new version, and the push result.
