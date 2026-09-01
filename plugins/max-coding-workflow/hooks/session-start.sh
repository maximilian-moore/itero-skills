#!/usr/bin/env bash
# Max's AI Coding Framework - SessionStart hook (shell fallback).
#
# For tools that run shell hooks. Claude Code uses hooks/session-start.js instead,
# registered automatically by the plugin; this file exists for hosts without plugin
# hooks. Keep the two in step - they are meant to produce the same output.
#
# Install to .claude/hooks/session-start.sh and register in .claude/settings.json.
# Prints nothing unless the repo is a framework project. Reports only, never writes,
# and never touches the network - no fetch, no pull. /start does that.

set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Not a framework project: say nothing at all.
[ -f project-status.md ] || [ -f backlog.md ] || exit 0

echo "=== PROJECT STATE (Max's AI Coding Framework) ==="
echo
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown (detached HEAD?)')"
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [ -n "$UPSTREAM" ]; then
  COUNTS=$(git rev-list --left-right --count "$UPSTREAM...HEAD" 2>/dev/null || true)
  if [ -n "$COUNTS" ]; then
    echo "Tracking $UPSTREAM: $(echo "$COUNTS" | awk '{print $2" ahead, "$1" behind"}') (as of last fetch)"
  else
    echo "Tracking $UPSTREAM: position unknown"
  fi
else
  echo "Tracking: no upstream branch set"
fi
echo
echo "--- Uncommitted changes ---"
if CHANGES=$(git status --porcelain 2>/dev/null); then
  if [ -z "$CHANGES" ]; then echo "(clean)"; else echo "$CHANGES" | head -20; fi
else
  # Never print "(clean)" on failure. A tree wrongly believed clean is what makes
  # /start think it is safe to pull over the user's uncommitted work.
  echo "(could not read git status - treat the tree as possibly dirty)"
fi
echo
echo "--- Last 10 commits ---"
git log --oneline -10 2>/dev/null || echo "(no commits yet)"
echo

STATUS_FILE="project-status.md"
if [ -f "$STATUS_FILE" ]; then
  echo "--- project-status.md ---"
  head -120 "$STATUS_FILE" 2>/dev/null || echo "(could not read $STATUS_FILE)"
  echo

  # Staleness check: is the repo ahead of the status file?
  LAST_COMMIT_EPOCH=$(git log -1 --format=%ct 2>/dev/null || echo 0)
  STATUS_LINE=$(grep -m1 -i '^Last updated:' "$STATUS_FILE" 2>/dev/null | sed 's/^[Ll]ast [Uu]pdated:[[:space:]]*//')
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
  echo "backlog.md exists but project-status.md does not. Offer to create it from the"
  echo "template before doing any other work; it is the framework's entry point."
  echo
fi

if [ -f backlog.md ]; then
  # Body of a '## Heading' section, up to the next '##' or end of file.
  section() { awk -v h="$1" 'BEGIN{IGNORECASE=1} $0 ~ "^##[ \t]+" h "[ \t]*$" {f=1;next} /^##[ \t]/{f=0} f' backlog.md 2>/dev/null; }

  # Only print the block when the section actually exists, matching session-start.js.
  NEXT_UP=$(section "next up" | sed '/^[[:space:]]*$/d' | head -10)
  if [ -n "$NEXT_UP" ]; then
    echo "--- Backlog: Next up ---"
    echo "$NEXT_UP"
    echo
  fi

  # Count inside the Items table only. Counting the whole file would also match rows
  # in Known issues or Cancelled whose text happens to be a status word.
  ITEMS=$(section "items")
  [ -n "$ITEMS" ] || ITEMS=$(cat backlog.md 2>/dev/null)
  READY=$(printf '%s\n' "$ITEMS" | grep -ciE '^\|.*\|[[:space:]]*ready[[:space:]]*\|' || true)
  INFLIGHT=$(printf '%s\n' "$ITEMS" | grep -ciE '^\|.*\|[[:space:]]*implementation[[:space:]]*\|' || true)
  echo "Backlog: ${READY:-0} item(s) ready, ${INFLIGHT:-0} in implementation."
  echo
fi

echo "Framework reminders: one PR per backlog item; nothing merges without verify +"
echo "subagent review + human acceptance test + status update; stop and ask after"
echo "three failed attempts at the same problem."
echo
echo "Now do the rest of the session-start ritual: fetch from the remote, pull if the"
echo "branch is behind and the tree is clean, then state back to the user in two or three"
echo "lines where the project is and what the next step is, and ask whether to proceed."
echo "=== END PROJECT STATE ==="
