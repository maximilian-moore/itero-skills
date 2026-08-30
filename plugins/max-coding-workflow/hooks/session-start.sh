#!/usr/bin/env bash
# Max's AI Coding Framework - SessionStart hook
# Injects current repo state into a new session so the model orients itself
# before doing anything. Stdout is added to the session context.
# Install to .claude/hooks/session-start.sh and register in .claude/settings.json.

set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

echo "=== PROJECT STATE (Max's AI Coding Framework) ==="
echo
echo "Branch: $(git branch --show-current 2>/dev/null || echo unknown)"
echo
echo "--- Uncommitted changes ---"
CHANGES=$(git status --porcelain 2>/dev/null)
if [ -z "$CHANGES" ]; then echo "(clean)"; else echo "$CHANGES" | head -20; fi
echo
echo "--- Last 10 commits ---"
git log --oneline -10 2>/dev/null || echo "(no commits yet)"
echo

STATUS_FILE="project-status.md"
if [ -f "$STATUS_FILE" ]; then
  echo "--- project-status.md ---"
  cat "$STATUS_FILE"
  echo

  # Staleness check: is the repo ahead of the status file?
  LAST_COMMIT_EPOCH=$(git log -1 --format=%ct 2>/dev/null || echo 0)
  STATUS_LINE=$(grep -m1 -i '^Last updated:' "$STATUS_FILE" | sed 's/^[Ll]ast [Uu]pdated:[[:space:]]*//')
  STATUS_EPOCH=$(date -d "$STATUS_LINE" +%s 2>/dev/null || echo 0)
  if [ "$STATUS_EPOCH" -gt 0 ] && [ "$LAST_COMMIT_EPOCH" -gt "$((STATUS_EPOCH + 86400))" ]; then
    echo "!!! STALE STATUS !!!"
    echo "The last commit is newer than the 'Last updated' date in project-status.md."
    echo "Tell the user the status file may be out of date and offer to reconstruct"
    echo "it from git log before doing any other work."
    echo
  fi
else
  echo "--- No project-status.md found ---"
  echo "This project is not yet set up with the framework, or you are in the wrong"
  echo "directory. If starting fresh, begin at Phase 0."
  echo
fi

echo "Framework reminders: one PR per backlog item; nothing merges without verify +"
echo "subagent review + human acceptance test + status update; stop and ask after"
echo "three failed attempts at the same problem."
echo "=== END PROJECT STATE ==="
