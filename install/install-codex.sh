#!/usr/bin/env bash
# Install Itero Skills for OpenAI Codex.
#
#   ./install/install-codex.sh                      install every skill, all projects
#   ./install/install-codex.sh max-coding-workflow  install one skill
#   ./install/install-codex.sh --project            install into the current repo only
#
# Codex reads skills from .agents/skills, walking up from the working directory,
# so a personal install at ~/.agents/skills is available everywhere.

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCOPE="user"
SKILLS=()

for arg in "$@"; do
  case "$arg" in
    --project) SCOPE="project" ;;
    --user)    SCOPE="user" ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    -*)        echo "Unknown option: $arg" >&2; exit 1 ;;
    *)         SKILLS+=("$arg") ;;
  esac
done

if [ ${#SKILLS[@]} -eq 0 ]; then
  for d in "$ROOT"/plugins/*/skills/*/; do SKILLS+=("$(basename "$d")"); done
fi

if [ "$SCOPE" = "project" ]; then
  BASE="$(pwd)/.agents/skills"; WHERE="this project"
else
  BASE="$HOME/.agents/skills"; WHERE="all projects"
fi

mkdir -p "$BASE"
for name in "${SKILLS[@]}"; do
  SRC="$(find "$ROOT/plugins" -type d -path "*/skills/$name" -print -quit)"
  if [ -z "$SRC" ]; then echo "Skill not found: $name" >&2; exit 1; fi
  rm -rf "${BASE:?}/$name"
  cp -R "$SRC" "$BASE/$name"
  echo "  $name -> $BASE/$name"
done

echo
echo "Installed for Codex ($WHERE)."
echo "Start a new session. Run /skills to confirm, or invoke one directly with"
echo "\$skill-name. Codex also selects a skill on its own when a task matches its"
echo "description."
