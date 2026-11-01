#!/usr/bin/env bash
# Install the ritual shortcuts of max-coding-workflow (/start, /kickoff, /plan,
# /implement, /review, /checkpoint, /handover) into the current project, for tools that
# read project command files from .claude/commands/ (Claude Code).
#
# Needed when the skill folder was linked or copied into a project on its own, without
# its plugin. The marketplace plugin install already provides the commands, namespaced.
#
#   scripts/install-commands.sh           link them: they follow skill updates, gitignored
#   scripts/install-commands.sh --copy    copy them: commit them, e.g. for cloud sessions
#   scripts/install-commands.sh --force   also replace command files of the same name
#
# Run it from anywhere inside the project. Without --force it never replaces a command
# file that is not a link to this skill.

set -euo pipefail

MODE="link"
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --copy)    MODE="copy" ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *)         echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# Resolve symlinks: the skill is often linked into a project from a central folder.
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
PLUGIN_DIR="$(cd "$SKILL_DIR/../.." && pwd -P)"
CMD_SRC="$PLUGIN_DIR/commands"

if [ ! -d "$CMD_SRC" ]; then
  echo "No commands/ folder next to this skill (looked in $CMD_SRC)." >&2
  echo "Install the skill with its plugin (docs/INSTALL.md in the skill repository)," >&2
  echo "or run the rituals from references/ - they carry the same instructions." >&2
  exit 1
fi

PROJECT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DEST="$PROJECT/.claude/commands"
mkdir -p "$DEST"

installed=()
skipped=()
for f in "$CMD_SRC"/*.md; do
  [ -e "$f" ] || continue
  name="$(basename "$f")"
  target="$DEST/$name"
  if [ -e "$target" ] && [ "$FORCE" -eq 0 ] && [ "$(readlink "$target" || true)" != "$f" ]; then
    skipped+=("${name%.md}")
    continue
  fi
  rm -f "$target"
  if [ "$MODE" = "copy" ]; then cp "$f" "$target"; else ln -s "$f" "$target"; fi
  installed+=("$name")
done

# Links point into this machine's skill folder, so they must not be committed.
if [ "$MODE" = "link" ] && [ ${#installed[@]} -gt 0 ]; then
  gi="$PROJECT/.gitignore"
  header_done=0
  for name in "${installed[@]}"; do
    line=".claude/commands/$name"
    if ! grep -qxF "$line" "$gi" 2>/dev/null && ! grep -qxF ".claude/commands/" "$gi" 2>/dev/null; then
      if [ "$header_done" -eq 0 ]; then
        printf '\n# Ritual shortcuts linked from the max-coding-workflow skill (machine-specific links)\n' >> "$gi"
        header_done=1
      fi
      echo "$line" >> "$gi"
    fi
  done
  [ "$header_done" -eq 1 ] && echo "Added the linked command files to .gitignore."
fi

if [ ${#installed[@]} -gt 0 ]; then
  echo "Installed into $DEST ($MODE):"
  for name in "${installed[@]}"; do echo "  /${name%.md}"; done
fi
if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped, a command of the same name already exists: ${skipped[*]}"
  echo "Rename or remove those files, or run again with --force to replace them."
fi
echo "If the commands do not show up in your tool, start a new session."
