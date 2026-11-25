#!/usr/bin/env bash
# Install a local pre-push guard into a repo: refuses to force-push or delete main/master.
#
# Why local: GitHub branch protection and rulesets need GitHub Pro for private repos
# (checked 2026-11-07: HTTP 403 "Upgrade to GitHub Pro"). This guard covers the destructive
# cases for agents running with full access. It does not stop an agent that passes
# --no-verify; PROTOCOL.md forbids that.
#
#   install-git-guard.sh <repo-path> [<repo-path> ...]
#
# Keeps an existing pre-push hook: it is renamed to pre-push.local and still runs first.
set -euo pipefail

for repo in "$@"; do
  hooks="$(git -C "$repo" rev-parse --git-path hooks)"
  case "$hooks" in /*) ;; *) hooks="$repo/$hooks" ;; esac
  mkdir -p "$hooks"
  hook="$hooks/pre-push"
  if [ -f "$hook" ] && ! grep -q 'HQ git guard' "$hook"; then
    mv "$hook" "$hooks/pre-push.local"
  fi
  cat > "$hook" <<'HOOK'
#!/usr/bin/env bash
# HQ git guard: no force-push to, and no deletion of, main or master.
# Installed by <WORKSPACE_ROOT>/_hq/bin/install-git-guard.sh
hooks_dir="$(dirname "$0")"
if [ -x "$hooks_dir/pre-push.local" ]; then
  input="$(cat)"
  printf '%s\n' "$input" | "$hooks_dir/pre-push.local" "$@" || exit $?
else
  input="$(cat)"
fi
zero=0000000000000000000000000000000000000000
while read -r local_ref local_sha remote_ref remote_sha; do
  [ -z "${remote_ref:-}" ] && continue
  case "$remote_ref" in
    refs/heads/main|refs/heads/master) ;;
    *) continue ;;
  esac
  if [ "$local_sha" = "$zero" ]; then
    echo "HQ git guard: deleting ${remote_ref#refs/heads/} on the remote is not allowed." >&2
    exit 1
  fi
  if [ "$remote_sha" != "$zero" ] && ! git merge-base --is-ancestor "$remote_sha" "$local_sha" 2>/dev/null; then
    echo "HQ git guard: this push would rewrite ${remote_ref#refs/heads/} (force-push). Not allowed." >&2
    echo "Fetch and integrate the remote changes instead. If you really need this, ask <OWNER>." >&2
    exit 1
  fi
done <<< "$input"
exit 0
HOOK
  chmod +x "$hook"
  echo "guard installed: $hook"
done
