#!/usr/bin/env bash
# Scan the full git history for secret-shaped strings.
# Run before making a repository public. A safety net, not a guarantee -
# use gitleaks as well if you can install it.

set -uo pipefail
echo "Scanning full git history for likely secrets..."
echo

PATTERNS=(
  'sk-ant-[A-Za-z0-9_-]{20,}'
  'sk-[A-Za-z0-9]{32,}'
  'ghp_[A-Za-z0-9]{30,}'
  'github_pat_[A-Za-z0-9_]{30,}'
  'AKIA[0-9A-Z]{16}'
  'AIza[0-9A-Za-z_-]{30,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  '(password|passwd|secret|api_key|apikey|access_token)["'\'' ]*[:=]["'\'' ]*[^"'\'' ,;)}$]{8,}'
  'postgres(ql)?://[^:]+:[^@]+@'
  'mongodb(\+srv)?://[^:]+:[^@]+@'
)

FOUND=0
for p in "${PATTERNS[@]}"; do
  HITS=$(git log -p --all 2>/dev/null | grep -nEi "$p" | grep -v '\.example' | head -5)
  if [ -n "$HITS" ]; then
    FOUND=1
    echo "POSSIBLE MATCH  [$p]"
    echo "$HITS" | cut -c1-160
    echo
  fi
done

echo "--- Files ever committed that look sensitive ---"
git log --all --pretty=format: --name-only 2>/dev/null | sort -u \
  | grep -Ei '(^|/)\.env($|\.)|\.pem$|\.p12$|\.pfx$|id_rsa|\.key$|credentials|secrets?\.(json|ya?ml)' \
  | grep -v '\.example' || echo "(none)"
echo

if [ "$FOUND" -eq 1 ]; then
  echo "RESULT: possible secrets found in history."
  echo "ROTATE every affected credential at its source before doing anything else."
  echo "Deleting the commit does not un-leak it. Rotation does."
  exit 1
fi
echo "RESULT: no obvious secrets found. This is not a guarantee - review manually too."
