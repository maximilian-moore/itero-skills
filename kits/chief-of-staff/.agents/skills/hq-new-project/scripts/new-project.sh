#!/usr/bin/env bash
# Set up a new project so <OWNER> can start the kickoff right away, with no manual steps.
#
#   new-project.sh <name> [--github private|public|none] [--skills "skill-a skill-b"]
#                  [--title "Display name"] [--root DIR] [--no-t3] [--no-registry]
#
# Defaults: --github private, --root <WORKSPACE_ROOT>.
# Creates: folder + git repo (main), .gitignore, AGENTS.md (+ CLAUDE.md, GEMINI.md),
# <WORKFLOW_SKILL> and extra skills linked in, ritual commands, starter scripts,
# first commit, local push guard, GitHub repo, optional T3 project, HQ registry row.
set -euo pipefail

DEV="<WORKSPACE_ROOT>"
HQ="$DEV/_hq"
MCW="$DEV/agent-skills/skills/<WORKFLOW_SKILL>"
INSTALL="$DEV/agent-skills/scripts/install.sh"

name="${1:-}"; shift || true
github="private"; extra=""; title=""; root="$DEV"; t3=1; registry=1
while [ $# -gt 0 ]; do
  case "$1" in
    --github) github="$2"; shift 2 ;;
    --skills) extra="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    --root) root="$2"; shift 2 ;;
    --no-t3) t3=0; shift ;;
    --no-registry) registry=0; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

if ! [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]]; then
  echo "Name must be 1-64 characters: letters, digits, dot, dash, underscore; no spaces." >&2; exit 2
fi
case "$github" in private|public|none) ;; *) echo "--github must be private, public or none" >&2; exit 2 ;; esac
[ -n "$title" ] || title="$name"
dir="$root/$name"
if [ -e "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
  echo "$dir already exists and is not empty. Stopping." >&2; exit 1
fi
today="$(date +%Y-%m-%d)"

echo "==> Folder and git"
mkdir -p "$dir"
cd "$dir"
git init -q -b main

echo "==> .gitignore, AGENTS.md, CLAUDE.md, GEMINI.md"
cp "$MCW/assets/templates/gitignore.txt" .gitignore
sed "s/\[project\]/$name/" "$MCW/assets/templates/AGENTS-template.md" > AGENTS.md
cat >> AGENTS.md <<EOF

## HQ
This project is run by HQ (\`$HQ\`). In a thread that starts with "HQ launch", read
\`$HQ/PROTOCOL.md\` first. For review, security, testing and debugging, follow
\`$HQ/skills.md\`, not a built-in command of your tool.
EOF
printf '@AGENTS.md\n' > CLAUDE.md
ln -s AGENTS.md GEMINI.md

echo "==> README and starter scripts"
cat > README.md <<EOF
# $title

Set up by HQ on $today. Next step: the kickoff interview (<WORKFLOW_SKILL> Phases 1 to 4).
EOF
mkdir -p scripts docs
cp "$MCW/scripts/check-requirement.sh" "$MCW/scripts/scan-secrets.sh" scripts/
cat > scripts/verify.sh <<'EOF'
#!/usr/bin/env bash
# The merge gate. Must exit 0 before any review or merge.
# Stack-neutral starter from HQ setup. Phase 3 of the kickoff adds lint, types, tests and build
# for the chosen stack (template: <WORKFLOW_SKILL> assets/templates/verify.sh).
set -e
echo "==> Requirements"
bash scripts/check-requirement.sh
echo
echo "All checks passed (starter gate: add the stack's checks in Phase 3)."
EOF
chmod +x scripts/*.sh

echo "==> Skills (linked, gitignored): <WORKFLOW_SKILL> $extra"
# shellcheck disable=SC2086
bash "$INSTALL" --project <WORKFLOW_SKILL> $extra

echo "==> Ritual commands (/start, /kickoff, /plan, /implement, /review, /checkpoint, /handover)"
bash .agents/skills/<WORKFLOW_SKILL>/scripts/install-commands.sh || echo "  (commands not installed; the rituals still work from references/)"

echo "==> First commit"
git add -A
git commit -q -m "chore: project setup by HQ"

echo "==> Push guard (no force-push or deletion of main)"
bash "$HQ/bin/install-git-guard.sh" .

remote="none"
if [ "$github" != "none" ]; then
  echo "==> GitHub repo ($github)"
  gh repo create "$name" "--$github" --source . --remote origin --push
  remote="$(git remote get-url origin)"
fi

project_id="not added"
if [ "$t3" -eq 1 ]; then
  if command -v t3 >/dev/null 2>&1; then
  echo "==> T3 project (optional)"
  out=$(mktemp)
  t3 project add "$dir" --title "$title" > "$out" 2>&1 || true
  project_id=$(grep -oE '[0-9a-f-]{36}' "$out" | head -n1 || echo "-")
  rm -f "$out"
else
  project_id="-"
fi
echo "  skills:     <WORKFLOW_SKILL> $extra"
echo "  next:       launch the kickoff lead thread (see SKILL.md step 4)"
