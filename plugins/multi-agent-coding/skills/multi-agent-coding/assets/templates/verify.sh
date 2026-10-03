#!/usr/bin/env bash
# The multi-agent merge gate. Must exit 0 before any code review or merge.
# Enforces lint, types, tests, build, and environment variable contracts.
set -e

echo "==> 1. Lint"
npm run lint

echo "==> 2. Type Check"
npm run typecheck

echo "==> 3. Automated Tests"
npm test

echo "==> 4. Build"
npm run build

echo "==> 5. Secrets Contract Check (.env.example)"
if [ -f .env.example ]; then
  # Simple sanity check: ensure .env.example is not empty
  if [ ! -s .env.example ]; then
    echo "Error: .env.example is empty."
    exit 1
  fi
fi

echo
echo "All verification checks passed."
