#!/usr/bin/env bash
# package.sh — Build a clean, shareable plugin archive of the aise-assistant plugin.
#
# Strips personal about/ files and runtime output dirs; restores placeholder
# templates so new users land in the /assistant-setup onboarding flow.
#
# Usage:
#   ./scripts/package.sh              # outputs aise-assistant-vX.Y.Z.plugin to parent dir
#   ./scripts/package.sh --out <dir>  # write plugin to a specific directory
#
# Output: aise-assistant-vX.Y.Z.plugin where X.Y.Z is read from .claude-plugin/plugin.json
# The .plugin extension is required for installation via the Claude Code / Cowork UI.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
PARENT_DIR="$(dirname "$PLUGIN_DIR")"
OUT_DIR="$PARENT_DIR"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out)
      OUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 [--out <output-dir>]" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$OUT_DIR" ]]; then
  echo "Error: output directory not found: $OUT_DIR" >&2
  exit 1
fi

# Read version from plugin.json
VERSION=$(python3 -c "import json,sys; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['version'])")
PLUGIN_NAME=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['name'])")
# Folder inside the zip must match the plugin name (spec requirement).
# The zip filename still includes the version for easy identification.
PACKAGE_NAME="$PLUGIN_NAME"
ZIP_PATH="$OUT_DIR/${PLUGIN_NAME}-v${VERSION}.plugin"

echo "aise-assistant packager"
echo "  version : $VERSION"
echo "  source  : $PLUGIN_DIR"
echo "  output  : $ZIP_PATH"
echo ""

# Stage into a temp dir
STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT

STAGED="$STAGING/$PACKAGE_NAME"
# Note: we stage into a named subfolder for rsync convenience, then zip from
# *inside* that folder so the ZIP root contains the plugin contents directly
# (no wrapping parent directory). The Claude plugin validator requires this.

# Copy everything except personal files, runtime dirs, and junk.
# commands/ is excluded: skills/ covers the same slash commands under the plugin
# namespace, and shipping both causes a duplicate-name registration error.
rsync -a \
  --exclude='.DS_Store' \
  --exclude='.git/' \
  --exclude='.github/' \
  --exclude='.claude/' \
  --exclude='about/identity.md' \
  --exclude='about/voice.md' \
  --exclude='about/workspace.md' \
  --exclude='commands/' \
  --exclude='CLAUDE.md' \
  --exclude='diagrams/' \
  --exclude='memory/' \
  --exclude='*.plugin' \
  --exclude='package.json' \
  --exclude='DEVELOPMENT.md' \
  "$PLUGIN_DIR/" "$STAGED/"

# Restore placeholder personal files from templates (so new users get the onboarding prompts)
for tpl in identity voice workspace; do
  src="$STAGED/about/templates/${tpl}.md.template"
  dst="$STAGED/about/${tpl}.md"
  if [[ -f "$src" ]]; then
    cp "$src" "$dst"
  fi
done

echo "  Staging contents:"
find "$STAGED" -not -name '.DS_Store' | sort | sed "s|$STAGED/||" | sed 's/^/    /'
echo ""

# Zip from inside the staged folder so there is NO wrapping parent directory.
# The ZIP root must contain .claude-plugin/, agents/, skills/, etc. directly.
# Remove any prior ZIP first — zip -r updates in place and would keep stale entries.
rm -f "$ZIP_PATH"
(cd "$STAGED" && zip -r "$ZIP_PATH" . -x "*.DS_Store")

echo "Package written: $ZIP_PATH"
echo "$(du -sh "$ZIP_PATH" | cut -f1) on disk"
