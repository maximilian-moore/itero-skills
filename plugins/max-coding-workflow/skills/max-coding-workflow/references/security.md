# Phase 0: Repo and secrets. Phase 6: Going public.

Two jobs live here. Phase 0 makes the repo safe to work in. Phase 6 makes it safe to
show the world. They are separated because `.gitignore` protects the future and does
nothing about the past.

---

## Phase 0.1 - Initialise the repo

If there is no repo yet, stop and set one up before writing a single line of code.
Without version control the user cannot undo an AI mistake, and undoing AI mistakes
is a routine part of this work, not an edge case.

```bash
git init
git branch -M main
gh repo create <name> --private --source=. --remote=origin
```

Private by default. Flipping private to public later is one click. Un-publishing a
leaked key is not.

Then: protect main. On GitHub, require a pull request before merging. If the user
finds branch protection too heavy for a solo project, the minimum substitute is a
hard rule that you never commit directly to main and never force-push it.

## Phase 0.2 - .gitignore, and telling the user what it does

Write the `.gitignore` from `assets/templates/gitignore.txt`, then **print a short
table to the user** explaining what is being excluded and why. Do not skip this. Most
accidental leaks happen because the person did not know a file was tracked.

| Ignored | Why |
|---|---|
| `.env`, `.env.*` (not `.env.example`) | Real API keys and passwords. The single most common leak. |
| `.claude/settings.local.json` | Machine-specific Claude settings, sometimes with tokens. |
| `node_modules/`, `venv/`, `__pycache__/` | Rebuildable from a lockfile. Bloats the repo and hides diffs. |
| `*.db`, `*.sqlite`, `data/` | Real user data. A privacy problem, not just a size one. |
| `.DS_Store`, `Thumbs.db` | OS clutter. Harmless, but it makes a public repo look careless. |
| `dist/`, `build/`, `.next/` | Build output. Regenerated every time, causes noisy conflicts. |
| `*.pem`, `*.key`, `id_rsa*`, `*.p12` | Private keys and certificates. |

## Phase 0.3 - Secrets: where they live and how they travel

The user works across machines and across tools. This is where that usually breaks,
so set it up properly the first time.

**The pattern:**

1. `.env.example` is committed. It lists every key the project needs, with empty or
   obviously fake values. This file is the contract.
2. `.env` is local, ignored, and never leaves the machine.
3. `docs/SETUP.md` says, for every single key: what it is, where to get it (the exact
   dashboard and page), whether it is free, and whether it can be regenerated.

`.env.example`:

```
# Anthropic API key - console.anthropic.com > API Keys
ANTHROPIC_API_KEY=

# Database URL - from your Supabase project settings > Database
DATABASE_URL=
```

**Moving to a second machine.** The user clones the repo, copies `.env.example` to
`.env`, opens `docs/SETUP.md`, and fills in the values from the listed sources. Never
email, Slack, or paste secrets into a chat window to move them. If a secret ever
appears in a chat transcript, treat it as compromised and rotate it.

**In Claude Code sessions.** Read secrets from the environment, never hardcode them,
and never echo them. If you need to confirm a key is set, check that the variable is
non-empty and print its length, not its value. Add `.env` to the deny list in
`.claude/settings.json` if the project has particularly sensitive keys.

**In deployment.** Secrets go into the host's secret store: Vercel environment
variables, Railway variables, GitHub Actions secrets. Not into the repo, not into a
config file, not into the frontend bundle. Anything shipped to a browser is public,
including "hidden" env vars in client-side code.

**When a key leaks.** Rotate first, scrub second. Rotation is the only step that
actually fixes it. Rewriting history with `git filter-repo` or BFG helps, but forks,
clones, and caches may already have the old commit, so a leaked key stays leaked until
it is revoked at the source.

## Phase 0.4 - The verify command

Create `scripts/verify.sh` early, even if it barely does anything at first. It grows
with the project, and having the hook in place from day one means it actually gets
used.

```bash
#!/usr/bin/env bash
set -e
npm run lint
npm run typecheck
npm test
npm run build
```

By the end of the first feature PR this must run lint, a type or syntax check, and at
least one real test. It is the gate in rule 2, and a gate that always passes is not a
gate.

---

## Phase 6 - Before making the repo public

Run this checklist in order and report each result to the user. Do not flip the repo
to public until every line passes.

**1. Scan the full history, not the working tree.**

```bash
./scripts/scan-secrets.sh
```

The script greps every commit for key-shaped strings. It is a safety net, not a
guarantee. If the user can install `gitleaks`, run that too, it is considerably better.

**2. Anything found gets rotated.** Not deleted. Rotated. Then decide with the user
whether to rewrite history or start a clean repo. For a small project, a fresh repo
with a single initial commit is often simpler and definitively safe.

**3. Check for embarrassment, not just danger.** Read through as a stranger would.
Hardcoded personal email addresses, internal company names, real customer data in test
fixtures, TODO comments that read as rude, commented-out experiments. Clean or remove.

**4. Keep work and personal strictly separate.** Anything touching an employer's
systems, data, internal tooling, or proprietary process does not go in a personal
public repo. Ever. If there is any doubt at all about whether a project is
work-adjacent, keep it private and tell the user why.

**5. README must let a stranger run it.** See `assets/templates/README.md`. A person
who has never seen the project should get it running from the README alone. If they
would need to ask you a question, the README is incomplete.

**6. Add a LICENSE.** Without one, nobody can legally use, fork, or contribute to the
code, which defeats the point of publishing. MIT is the usual choice for a shared
personal project. Ask the user rather than picking silently.

**7. Final look.** Repo description filled in, topics tagged, no dead links in the
README, default branch is main.
