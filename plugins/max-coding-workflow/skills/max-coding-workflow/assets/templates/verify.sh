#!/usr/bin/env bash
# The merge gate. Must exit 0 before any code review or merge.
# Start small, grow it as the project grows. A gate that always passes is not a gate.
set -e

echo "==> Lint"
npm run lint

echo "==> Types"
npm run typecheck

echo "==> Tests"
npm test

echo "==> Build"
npm run build

echo
echo "All checks passed."
