#!/usr/bin/env bash
# Install Itero Skills for Google Antigravity.
#
#   ./install/install-antigravity.sh                      every skill, this project
#   ./install/install-antigravity.sh max-coding-workflow  one skill
#   ./install/install-antigravity.sh --plugin             install as a CLI plugin,
#                                                         available in all projects
#
# Antigravity reads skills from .agents/skills, with .agent/skills kept for
# backward compatibility.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="project"
SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --plugin)  MODE="plugin" ;;
    --project) MODE="project" ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    -*)        echo "Unknown option: $arg" >&2; exit 1 ;;
    *)         SKILLS+=("$arg") ;;
  esac
done

if [ ${#SKILLS[@]} -eq 0 ]; then
  for d in "$ROOT"/plugins/*/skills/*/; do SKILLS+=("$(basename "$d")"); done
fi

for name in "${SKILLS[@]}"; do
  SRC="$(find "$ROOT/plugins" -type d -path "*/skills/$name" -print -quit)"
  if [ -z "$SRC" ]; then echo "Skill not found: $name" >&2; exit 1; fi
  PLUGIN_DIR="$(dirname "$(dirname "$SRC")")"

  if [ "$MODE" = "plugin" ]; then
    DEST="$HOME/.gemini/antigravity-cli/plugins/$(basename "$PLUGIN_DIR")"
    mkdir -p "$DEST/skills"
    rm -rf "${DEST:?}/skills/$name"
    cp -R "$SRC" "$DEST/skills/$name"
    [ -f "$PLUGIN_DIR/plugin.json" ] && cp "$PLUGIN_DIR/plugin.json" "$DEST/plugin.json"
    echo "  $name -> $DEST/skills/$name"
  else
    DEST="$(pwd)/.agents/skills"
    mkdir -p "$DEST"
    rm -rf "${DEST:?}/$name"
    cp -R "$SRC" "$DEST/$name"
    echo "  $name -> $DEST/$name"
  fi
done

echo
if [ "$MODE" = "plugin" ]; then
  echo "Installed as Antigravity plugins (all projects)."
else
  echo "Installed for Antigravity (this project)."
fi
echo "Restart Antigravity, then run /skills to confirm. Activation is implicit and"
echo "driven by the description field."
echo
echo "Note: hooks are not installed by this script. Antigravity uses its own hooks.json"
echo "format. For max-coding-workflow, either port hooks/session-start.sh yourself or"
echo "just run /start at the top of each session - it does the same reading and more."
