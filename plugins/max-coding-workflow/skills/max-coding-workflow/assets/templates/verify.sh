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

# End-to-end tests, from the first screen on (references/testing.md). Never skip,
# weaken or delete a test to get this green.
# echo "==> End-to-end"
# npx playwright test

echo "==> Build"
npm run build

echo
echo "All checks passed."
