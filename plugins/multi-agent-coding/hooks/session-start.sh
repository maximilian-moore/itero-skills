#!/usr/bin/env bash
# Multi-Agent Coding Framework - SessionStart hook (shell fallback).
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

[ -f project-status.md ] || [ -f backlog.md ] || exit 0

echo "=== PROJECT STATE (Multi-Agent Coding Framework) ==="
echo
echo "Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"

UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
if [ -n "$UPSTREAM" ]; then
  COUNTS=$(git rev-list --left-right --count "$UPSTREAM...HEAD" 2>/dev/null || true)
  if [ -n "$COUNTS" ]; then
    echo "Tracking $UPSTREAM: $(echo "$COUNTS" | awk '{print $2" ahead, "$1" behind"}') (as of last fetch)"
  fi
fi
echo

echo "--- Uncommitted changes ---"
if CHANGES=$(git status --porcelain 2>/dev/null); then
  if [ -z "$CHANGES" ]; then echo "(clean)"; else echo "$CHANGES" | head -20; fi
else
  echo "(could not read git status)"
fi
echo

echo "--- Last 10 commits ---"
git log --oneline -10 2>/dev/null || echo "(no commits yet)"
echo

if [ -f "project-status.md" ]; then
  echo "--- project-status.md ---"
  head -120 "project-status.md" 2>/dev/null
  echo
fi

if [ -f "docs/learnings.md" ]; then
  echo "--- Recent Learnings & Traps ---"
  head -20 "docs/learnings.md" 2>/dev/null
  echo
fi

echo "Multi-Agent reminders: Claim before code (remote lock); one PR per item;"
echo "Rebase before merge; harvest learnings into docs/learnings.md."
echo "=== END PROJECT STATE ==="
