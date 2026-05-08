# AISE Assistant — Developer / Maintainer Notes

This file is excluded from the plugin package. It's for whoever is maintaining or distributing this plugin.

---

## Packaging

```bash
cd aise-assistant
bash scripts/package.sh
# → writes aise-assistant-v<version>.plugin to the parent directory
```

Then validate before distributing:

```bash
bash scripts/validate.sh
# auto-finds the latest .plugin in the parent dir
```

The `.plugin` file can be installed via:
- **Cowork UI** — Settings → Extensions → upload the `.plugin` file
- **CLI** — `claude plugin marketplace add <path> --scope user` + `claude plugin install aise-assistant@<name>`

Version bumping is automatic — `package.sh` evaluates the git diff and bumps before building. See **Versioning** below to override.

---

## Versioning

`package.sh` reads `git diff HEAD` on every run, classifies the changes, bumps `.claude-plugin/plugin.json` → `"version"`, then packages.

| Change type | Bump |
|---|---|
| Skill, command, or agent **deleted** (capability removed for users) | **MAJOR** — `X+1.0.0` |
| Skill, command, or agent **added** (new capability) | **MINOR** — `X.Y+1.0` |
| Fix, polish, docs, schema/context/template edits, refactor | **PATCH** — `X.Y.Z+1` |

**Rules:**
- One commit, one bump level. If a change mixes additions and fixes, MINOR wins. If it mixes deletions and additions, MAJOR wins.
- Never skip versions — increment by 1 only.
- PATCH resets to 0 on a MINOR bump. Both MINOR and PATCH reset on a MAJOR bump.

**Override** — pass `--bump major|minor|patch` to skip the auto-detect:

```bash
bash scripts/package.sh --bump minor
```

**After packaging**, commit the `plugin.json` version bump:

```bash
git add .claude-plugin/plugin.json
git commit -m "chore: bump version to X.Y.Z"
git push
```

Users who have the marketplace added will get the update on their next `/plugin marketplace update` or auto-update.

---

## What gets packaged vs excluded

**Excluded by `scripts/package.sh`:**

| Path | Why |
|---|---|
| `.git/`, `.github/`, `.claude/` | Dev infrastructure |
| `.claude-plugin/marketplace.json` | Marketplace catalog — not part of the installable plugin |
| `about/identity.md`, `about/voice.md`, `about/workspace.md` | Personal files — replaced with placeholder templates from `about/templates/` at package time |
| `skills/` | See "commands/ vs skills/" below |
| `CLAUDE.md` | Not used in plugin installs — context is loaded per-invocation via the `aise-context` skill. Including it causes a Cowork validation failure (treated as an error in the skills/ validator). |
| `diagrams/`, `memory/` | Runtime output dirs |
| `DEVELOPMENT.md` | This file |
| `*.plugin`, `package.json` | Build artefacts |

Everything else (agents/, commands/, context/, templates/, scripts/, README.md, .claude-plugin/) is included.

---

## commands/ vs skills/

**`skills/` is the current shipping format** — as of v1.0.0, `package.sh` excludes `commands/` and ships `skills/`. The Cowork app validator was updated and now accepts the `skills/*/SKILL.md` format.

`commands/` remains in the repo as a reference (manually synced), but is no longer packaged. If you need to roll back to `commands/` for any reason, swap `--exclude='commands/'` back to `--exclude='skills/'` in `package.sh`.

**YAML safety rules for agent and skill frontmatter:**

1. **Colon-space** — quote any `description:` value that contains a colon-space (`: `). Unquoted colon-space breaks YAML parsing:

```yaml
# Bad — colon-space in unquoted string
description: Visual style: polished grid layout

# Good — rephrase with em-dash (preferred over quoting)
description: Visual style — polished grid layout
```

2. **Angle brackets** — never use `<` or `>` in a `description:` field. Cowork's validator runs the value through an HTML parser and rejects it silently. Use `{placeholder}` notation instead:

```yaml
# Bad — angle brackets in description
description: Saves artifacts to diagrams/<customer>/ and attaches to Notion.

# Good
description: Saves artifacts to diagrams/{customer}/ and attaches to Notion.
```

Note: angle brackets in the skill **body** (below the frontmatter) are fine — only the frontmatter fields are HTML-parsed.

---

## Agent files

`agents/*.md` are **procedure documents**, not registered subagent types. Skills invoke them by name; Claude reads and executes them inline. They are NOT registered via the plugin system — don't try to use them as `subagent_type` in the Agent tool.

Agent `tools:` frontmatter uses comma-separated format:

```yaml
---
name: session-prepper
description: ...
tools: Read, Grep, Glob, mcp__..., mcp__...
---
```

JSON array format (`tools: ["Read", ...]`) passes CLI validation but may fail the Cowork native validator. Keep it as a comma-separated string.

---

## Preserving personal about/ files on upgrade

The `about/identity.md`, `about/voice.md`, `about/workspace.md` files are personal — populated by `/assistant-setup`. When packaging, `package.sh` restores placeholder templates from `about/templates/` so new users land in the onboarding flow.

For upgrading an existing install (your own machine or a teammate's), use `scripts/upgrade.sh --source <new-version-dir>`. It preserves populated personal files and only overwrites plugin-owned files.

---

## Testing a new package before distributing

1. `bash scripts/package.sh` — build the `.plugin`
2. `bash scripts/validate.sh` — check structure + field presence
3. Install via Cowork UI (the native validator is stricter than the CLI) — confirm it shows as "Enabled" without "Validation failed"
4. **Fully quit and reopen Cowork** — slash commands from `commands/*.md` are registered at startup, not on hot-reload. Without a restart, Claude may see the plugin's skills/context loaded but the slash commands not yet wired, and will tell you to invoke things "as a skill" instead.
5. Run `/aise-assistant:assistant-help` to verify commands are registered
6. Run `/aise-assistant:assistant-setup` on a fresh install to confirm onboarding flow works

Note: in plugin mode (installed via Cowork), commands are prefixed with the plugin name: `/aise-assistant:<command>`. The agent that *executes* a command may have a different internal name (e.g., `/aise-assistant:assistant-setup` runs the `assistant-onboarding` agent). This is expected and not a bug.

---

## Debugging Cowork "Plugin validation failed"

The CLI (`claude plugin validate`) and Cowork's server-side validator have different strictness — the CLI passes things Cowork rejects. If `validate.sh` passes but Cowork still shows "Plugin validation failed", use the binary search approach below to isolate the bad file.

**Important:** Cowork's validator appears stateful. A failed install can cause the next install to also fail even if that plugin is clean. Always **restart Cowork between install attempts** when isolating failures, or test packages one at a time with a fresh session each time.

### Binary search procedure

**Step 1 — Confirm it's content, not structure.** Build a minimal stub (one skill, one agent, README, plugin.json) and install it. If the stub fails, the issue is structural (ZIP format, plugin.json fields). If it passes, the issue is in your content.

**Step 2 — Split by directory.** Build packages with each top-level directory in isolation (`skills/` only, `agents/` only, `context/` only, etc.) and install each. The one that fails contains the bad file.

**Step 3 — Split the failing directory in half.** Divide its files into two groups, build two packages, and install each. The failing half contains the bad file.

**Step 4 — Test individually.** Build one package per file in the failing half. The one that fails is the culprit.

**Step 5 — Fix and rebuild the full package.** Once identified, check the bad file's frontmatter against the YAML safety rules above, fix, and rebuild with `package.sh`.

A complete binary search across 20 skills takes about 5–6 rounds of installs. To build a single-skill test package quickly:

```bash
PARENT="/path/to/parent/dir"
SRC="/path/to/aise-assistant"
skill="draft-diagram"   # ← the skill to test

dir="$PARENT/test-single-$skill"
zip="$PARENT/aise-test-single-${skill}.plugin"
rm -rf "$dir" "$zip"
mkdir -p "$dir/.claude-plugin" "$dir/agents" "$dir/skills"
printf '{"name":"aise-test-%s","version":"1.0.0","description":"Single skill test.","author":{"name":"KM"},"repository":"https://github.com/test","license":"MIT"}\n' \
  "$skill" > "$dir/.claude-plugin/plugin.json"
echo "# test" > "$dir/README.md"
cp "$SRC/agents/notion-writer.md" "$dir/agents/"
cp -r "$SRC/skills/$skill" "$dir/skills/"
(cd "$dir" && zip -r "$zip" . -x "*.DS_Store")
```
