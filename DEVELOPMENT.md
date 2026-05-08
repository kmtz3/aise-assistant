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

**Version is stored in two files — both must be updated together:**
- `.claude-plugin/plugin.json` — used by the marketplace / Cowork installer
- `package.json` — used by local tooling (`npm run pack`, `npm run validate`)

`package.sh` only auto-bumps `plugin.json`. Always update `package.json` to match before committing.

| Change type | Bump | Auto-detected? |
|---|---|---|
| Skill, command, or agent **added or deleted** (capability roster changes) | **MAJOR** — `X+1.0.0` | Yes |
| Functional tweak to an existing capability (new behavior within a skill/agent) | **MINOR** — `X.Y+1.0` | No — pass `--bump minor` |
| Bug fix or behavior correction, no new functionality | **PATCH** — `X.Y.Z+1` | Default |

**Rules:**
- Never skip versions — increment by 1 only.
- MINOR and PATCH reset to 0 on a MAJOR bump. PATCH resets to 0 on a MINOR bump.
- MAJOR auto-detection wins over any manual default — if the diff shows a skill/command/agent added or removed, it bumps MAJOR regardless.

**Override** — pass `--bump major|minor|patch` to skip auto-detect:

```bash
bash scripts/package.sh --bump minor   # functional tweak to existing capabilities
bash scripts/package.sh --bump patch   # force patch even if roster changed (rare)
```

**After packaging**, commit both version files:

```bash
git add .claude-plugin/plugin.json package.json
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

## Path resolution: dev (repo root) vs installed

This is the most common source of silent breakage during dev testing.

**How it works when installed:**
`session-start.sh` runs at the start of every Claude session, discovers the real persistent plugin data directory (e.g. `~/.claude/plugins/data/aise-assistant-*/`), and writes its path to `~/.claude/aise-assistant.datadir`. Every agent that needs personal files reads the path from that pointer file:

```bash
PLUGIN_DATA_DIR=$(cat "$HOME/.claude/aise-assistant.datadir")
# → e.g. /Users/you/.claude/plugins/data/aise-assistant-abc123/
```

**What happens when running from the repo root:**
`session-start.sh` still runs, but the hook's `$CLAUDE_PLUGIN_DATA` is a volatile temp path, not the installed data dir. Claude will read `about/identity.md` from the plugin root — which in the repo is the TBD template (`about/templates/identity.md.template` staged as `about/identity.md`). Any agent that filters Notion by the user's UUID or writes in the user's name will pick up `<TBD>` values and produce broken queries or corrupt records.

**The `$CLAUDE_PLUGIN_DATA` env var is not usable.** It resolves to a volatile temp path in all contexts — including dev runs. Never use it directly. Always go through `~/.claude/aise-assistant.datadir`.

**Dev workaround:** To run agents locally with real personal values, populate a local `about/` dir and override the pointer file:

```bash
echo "/path/to/your/populated/about-dir" > ~/.claude/aise-assistant.datadir
```

You can point this at the installed plugin's data directory, or at any directory containing populated `identity.md`, `voice.md`, and `workspace.md` files.

---

## Onboarding guard (session-start warning)

`session-start.sh` checks whether `$PLUGIN_DATA_DIR/about/identity.md` still contains `<TBD` placeholder values and emits a warning to stderr if so. This fires on any fresh install or new-user scenario where `/assistant-setup` hasn't been run yet. It is harmless — the session proceeds normally — and disappears once setup is complete.

**Personal files are gitignored** (`about/identity.md`, `about/voice.md`, `about/workspace.md`). The repo only ships their templates (`about/templates/*.md.template`). If you're testing a fresh-install flow, expect to see this warning in the session output until you run `/aise-assistant:assistant-setup`.

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
