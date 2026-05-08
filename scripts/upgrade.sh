#!/usr/bin/env bash
# upgrade.sh — Safe upgrade script for aise-assistant plugin.
#
# Copies plugin-owned files from a new version while preserving personal about/
# files the user has already populated (no <TBD placeholders remaining).
#
# Usage:
#   ./scripts/upgrade.sh --source <path-to-new-version-dir>
#   ./scripts/upgrade.sh --check   (just audit current state, no writes)
#
# Plugin-owned (always replaced):  about/README.md, about/templates/
# Personal (preserved if populated): about/identity.md, about/voice.md, about/workspace.md
#
# A file is considered "populated" if it exists and contains no occurrence of <TBD.
# Any file that still has <TBD (i.e. was never filled in) is safe to overwrite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
ABOUT_DIR="$PLUGIN_DIR/about"

PERSONAL_FILES=("identity.md" "voice.md" "workspace.md")

SOURCE_DIR=""
CHECK_ONLY=false

# --- arg parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --check)
      CHECK_ONLY=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 --source <new-version-dir> | --check" >&2
      exit 1
      ;;
  esac
done

if [[ "$CHECK_ONLY" == false && -z "$SOURCE_DIR" ]]; then
  echo "Error: --source <path> is required unless --check is passed." >&2
  echo "Usage: $0 --source <new-version-dir> | --check" >&2
  exit 1
fi

if [[ -n "$SOURCE_DIR" && ! -d "$SOURCE_DIR" ]]; then
  echo "Error: source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

# --- helpers ---
is_populated() {
  local file="$1"
  [[ -f "$file" ]] && ! grep -q '<TBD' "$file" 2>/dev/null
}

# --- check mode ---
if [[ "$CHECK_ONLY" == true ]]; then
  echo "aise-assistant about/ file state:"
  for f in "${PERSONAL_FILES[@]}"; do
    target="$ABOUT_DIR/$f"
    if is_populated "$target"; then
      echo "  ✓ $f — populated (would be preserved on upgrade)"
    elif [[ -f "$target" ]]; then
      echo "  ○ $f — exists but unpopulated (would be overwritten on upgrade)"
    else
      echo "  ✗ $f — missing (would be created from template on upgrade)"
    fi
  done
  exit 0
fi

# --- upgrade mode ---
PRESERVED=()
RESTORED=()
CREATED=()

echo "aise-assistant upgrade — source: $SOURCE_DIR"
echo ""

# 1. Personal files: preserve if populated, otherwise restore from new source
for f in "${PERSONAL_FILES[@]}"; do
  target="$ABOUT_DIR/$f"
  src_template="$SOURCE_DIR/about/templates/${f%.md}.md.template"
  src_file="$SOURCE_DIR/about/$f"

  if is_populated "$target"; then
    PRESERVED+=("$f")
    echo "  ✓ $f — populated, preserved (skipped)"
  else
    # prefer the template from the new version; fall back to the source about/ file
    if [[ -f "$src_template" ]]; then
      cp "$src_template" "$target"
      RESTORED+=("$f")
      echo "  → $f — unpopulated, restored from new template"
    elif [[ -f "$src_file" ]]; then
      cp "$src_file" "$target"
      RESTORED+=("$f")
      echo "  → $f — unpopulated, copied from new source"
    else
      echo "  ⚠ $f — no source found; left unchanged"
    fi
  fi
done

echo ""

# 2. Plugin-owned files: always overwrite
echo "  Updating plugin-owned files..."

# about/README.md
if [[ -f "$SOURCE_DIR/about/README.md" ]]; then
  cp "$SOURCE_DIR/about/README.md" "$ABOUT_DIR/README.md"
  echo "  ↺ about/README.md — updated"
fi

# about/templates/ — replace entirely
if [[ -d "$SOURCE_DIR/about/templates" ]]; then
  rm -rf "$ABOUT_DIR/templates"
  cp -r "$SOURCE_DIR/about/templates" "$ABOUT_DIR/templates"
  echo "  ↺ about/templates/ — updated"
fi

# All other top-level plugin files (agents/, commands/, context/, scripts/, CLAUDE.md, etc.)
for item in CLAUDE.md README.md agents commands context scripts templates; do
  src="$SOURCE_DIR/$item"
  dst="$PLUGIN_DIR/$item"
  if [[ -e "$src" ]]; then
    rm -rf "$dst"
    cp -r "$src" "$dst"
    echo "  ↺ $item — updated"
  fi
done

echo ""
echo "─────────────────────────────────────────────────"

# 3. Summary + post-upgrade notice
if [[ ${#PRESERVED[@]} -gt 0 ]]; then
  preserved_list=$(IFS=', '; echo "${PRESERVED[*]}")
  echo ""
  echo "Personal about/ files detected and preserved (${preserved_list})."
  echo "Run /assistant-setup --update to check for drift against your updated role or preferences."
fi

if [[ ${#RESTORED[@]} -gt 0 ]]; then
  restored_list=$(IFS=', '; echo "${RESTORED[*]}")
  echo ""
  echo "Unpopulated files restored from template (${restored_list})."
  echo "Run /assistant-setup to populate them."
fi

echo ""
echo "Upgrade complete."
