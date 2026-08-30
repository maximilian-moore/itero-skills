#!/usr/bin/env bash
# Install Itero Skills for Claude Code WITHOUT the plugin marketplace.
#
# Prefer the marketplace where you can, it namespaces commands and handles updates:
#   /plugin marketplace add maximilian-moore/itero-skills
#   /plugin install <skill>@itero-skills
#
#   ./install/install-claude-manual.sh                      every skill, all projects
#   ./install/install-claude-manual.sh max-coding-workflow  one skill
#   ./install/install-claude-manual.sh --project            this repo only

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCOPE="user"
SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --project) SCOPE="project" ;;
    --user)    SCOPE="user" ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    -*)        echo "Unknown option: $arg" >&2; exit 1 ;;
    *)         SKILLS+=("$arg") ;;
  esac
done

if [ ${#SKILLS[@]} -eq 0 ]; then
  for d in "$ROOT"/plugins/*/skills/*/; do SKILLS+=("$(basename "$d")"); done
fi

if [ "$SCOPE" = "project" ]; then BASE="$(pwd)/.claude"; WHERE="this project"
else BASE="$HOME/.claude"; WHERE="all projects"; fi

mkdir -p "$BASE/skills" "$BASE/commands"
COPIED_CMDS=0
for name in "${SKILLS[@]}"; do
  SRC="$(find "$ROOT/plugins" -type d -path "*/skills/$name" -print -quit)"
  if [ -z "$SRC" ]; then echo "Skill not found: $name" >&2; exit 1; fi
  PLUGIN_DIR="$(dirname "$(dirname "$SRC")")"

  rm -rf "${BASE:?}/skills/$name"
  cp -R "$SRC" "$BASE/skills/$name"
  echo "  $name -> $BASE/skills/$name"

  if [ -d "$PLUGIN_DIR/commands" ]; then
    for f in "$PLUGIN_DIR/commands/"*.md; do
      [ -e "$f" ] || continue
      cp "$f" "$BASE/commands/$(basename "$f")"
      COPIED_CMDS=1
    done
  fi
done

echo
echo "Installed for Claude Code ($WHERE)."
if [ "$COPIED_CMDS" -eq 1 ]; then
  echo
  echo "Slash commands were copied to $BASE/commands/ unnamespaced, so names like"
  echo "/plan and /review can collide with commands you already have. The marketplace"
  echo "install avoids that by namespacing them as /<plugin>:<command>."
fi
