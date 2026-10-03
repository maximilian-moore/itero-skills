---
name: multi-agent-coding
description: >
  Multi-Agent Coding Framework - a disciplined, repo-first process for teams and
  multiple AI coding agents working in the same codebase. Coordinates concurrent
  work without collisions via remote branch claiming, orchestrator-worker subagent
  delegation to prevent context bloat, adversarial code reviews, a lean active backlog
  with delivered archives, a shared repository playbook for continuous learnings, and
  project velocity/cost tracking. Use this skill whenever multiple agents or team
  members build together, when starting or resuming work in a collaborative repo, or
  saying "implement the next item", "claim task", "start a multi-agent session",
  "review this PR", "update project status", "check repo learnings", or "show project metrics".
---

# Multi-Agent Coding Framework

A process for building software collaboratively with multiple AI agents and human
team members without stepping on each other's toes, bloating context windows, or
losing hard-won institutional knowledge.

The core idea: **the repository is the shared coordination layer and memory.**
Chat sessions are ephemeral; context windows fill up and die; agents switch machines.
Git and markdown files in the repo are the durable truth. Every claim, design decision,
status transition, repository trick, and velocity metric is recorded in git so any
agent or human can pick up seamlessly.

---

## The seven rules

These apply across all phases. They prevent collisions, context degradation, and drift.

**1. One PR = one backlog item.**
Never mix unrelated fixes into an active feature diff. Sprawling PRs cause severe
merge conflicts across branches, make code review ineffective, and obscure what shipped.
Anything outside the current plan goes straight to `backlog.md` as an `idea`.

**2. Claim before code (Zero collisions).**
Never start coding on an item without asserting an active claim. An item is claimed
only when its status is set to `implementation` in `backlog.md`, tied to an `Owner`
(agent or human ID), and its feature branch `feat/BL-XXX-<owner>-<slug>` is pushed
to the remote. Before claiming, every agent fetches remote branches; if an item is
already claimed, pick another unblocked item.

**3. Rebase-clean merge gate.**
Nothing merges to `main` without:
- An upstream rebase: `git fetch origin main && git rebase origin/main`
- Deterministic lockfile regeneration (clean install, never manual merge resolution)
- Verified migration sequence (no duplicate numbers or schema divergence)
- Passing `verify.sh` (lint + build + automated tests)
- Adversarial code review with High and Medium findings resolved
- Human acceptance test documented in plain language
- Project status and delivered archive updated

**4. Orchestrate high, delegate low (Context hygiene).**
The main conversation agent acts as the **Orchestrator**. It tracks overall status,
communicates with the user, plans requirements, and delegates intensive coding and
review loops to disposable **Worker Subagents**. This protects the main context window
from being flooded by hundreds of compiler runs, file reads, and test logs.

**5. Adversarial review pass.**
Code is reviewed in a fresh, scoped context that never saw the implementation reasoning.
The reviewer evaluates against a strict defect checklist. Security vulnerabilities,
race conditions, and data loss risks are never classified as Low priority.

**6. Continuous knowledge harvesting.**
Every checkpoint requires a learning check: *Did this PR uncover a repository-specific
speedup, a framework trap, a testing trick, or a reusable pattern?* If yes, it is
recorded in `docs/learnings.md`. Future sessions ingest these learnings at startup so
no agent repeats an expensive mistake.

**7. Single source of truth.**
Active items live in `backlog.md`. Completed items move to `docs/delivered.md`.
Cancelled items move to `docs/cancelled.md`. Ephemeral state lives in `project-status.md`.
Never duplicate facts across files—link by ID.

---

## Every session starts the same way

This is the `/start` ritual. Run it before taking any other action:

1. **Sync and inspect remote:**
   ```bash
   git status
   git fetch --all --prune
   git branch -r
   git log --oneline -10
   ```
2. **Handle working tree:**
   If the branch is clean and tracking upstream, `git pull --ff-only`. If uncommitted
   changes exist, do not pull—report them and ask the user. Never risk overwriting work.
3. **Scan active claims & detect stale locks:**
   Read `project-status.md` (section `## In Flight`) and `git branch -r origin/feat/*`.
   Check if any claimed branch has been inactive for > 24 hours. Report in-flight tasks
   and warn if a lock appears abandoned.
4. **Ingest status and learnings:**
   Read `project-status.md`, the `Next up` list in `backlog.md`, and recent entries in
   `docs/learnings.md`. The agent immediately inherits current project state and team
   wisdom.
5. **Check for drift:**
   Is the newest commit newer than the status file? Does an item sit in `implementation`
   without an active remote branch? Reconcile before starting work.
6. **State status and ask:**
   In two or three plain-language sentences: summarize what works, list active in-flight
   agents, state the next unblocked item, and ask whether to proceed.

---

## The phases

| Phase | What happens | Reference | Ends with |
|---|---|---|---|
| 0 | Setup: git, .gitignore, secrets, verify script | `references/security.md` | Clean repo, `.env.example`, `verify.sh` |
| 1 | Kickoff interview: vision, users, milestones | `references/kickoff.md` | Feature list & milestones defined |
| 2 | Backlog: active backlog with epics, IDs, dependencies | `references/backlog.md` | `backlog.md` with Next Up & In Flight |
| 3 | Architecture: stack, boundaries, first ADRs | `references/architecture.md` | `architecture.md` + decision log |
| 4 | User journey: screens, flows, design tokens | `references/ux-flow.md` | `docs/user-journey.md` |
| 5 | Multi-agent build loop: claim, plan, build, review, merge | `references/orchestrator.md`, `references/concurrency.md`, `references/checkpoint.md` | Merged PR, archived delivery, harvested learning, logged metric |
| 6 | Public readiness & handoff | `references/security.md` | Clean history, scanned secrets, README, LICENSE |

Read reference files on demand, not all at once.

---

## Phase 5: The multi-agent build loop

This is the repeating heartbeat of development.

```
[Orchestrator: Pick Item] ──► [Claim Remote Lock] ──► [Write & Approve Plan]
                                                               │
                                                               ▼
[Checkpoint & Merge] ◄── [Adversarial Review] ◄── [Worker Subagent: Build & Test]
```

### 1. Pick and lock the item (`/implement`)
Take the top unblocked `ready` item from `Next up` in `backlog.md`, or confirm the user's
choice.
- Check `git branch -r`: Ensure no branch exists matching `origin/feat/BL-XXX-*`.
- Update `backlog.md`: Set status to `implementation` and record `Owner: <actor-id>`.
- Update `project-status.md`: Add row to `## In Flight`.
- Create branch `feat/BL-XXX-<actor-id>-<slug>` and immediately push it to `origin`
  with commit `chore(BL-XXX): claim task by <actor-id>`. The remote branch is the
  distributed lock.

### 2. Implementation plan
Follow `references/planning.md`. Write `docs/plans/BL-XXX-plan.md` using the template.
Explicitly assess:
- Scope & files touched
- Schema & database migration impact (`Yes/No`)
- Dependencies & lockfile impact (`Yes/No`)
- Automated tests & plain-language human acceptance test
Stop and present the plan to the user. Do not code until approved.

### 3. Delegate to worker subagent
Follow `references/orchestrator.md`. The orchestrator spawns a **Worker Subagent**
with a scoped prompt containing:
- The approved plan and requirement file
- Relevant file paths and architecture constraints
- Instructions to write code and tests together, and run `verify.sh`
*(If running in a tool without subagent support, execute the worker instructions in the
current session following the fallback guidelines in `references/orchestrator.md`.)*

### 4. Rebase and resolve dependencies
Before review or merge, the branch must catch up with `origin/main`:
```bash
git fetch origin main
git rebase origin/main
```
- If dependencies changed, run package manager clean install to re-generate the lockfile.
- If migrations diverged, re-order migration sequence.
- Run `verify.sh`. It must pass cleanly.

### 5. Adversarial code review (`/review`)
Follow `references/review.md`. Spawn an independent **Reviewer Subagent** with only:
the diff (`git diff origin/main...HEAD`), requirement file, and checklist.
- The reviewer checks for security, race conditions, edge cases, and regressions.
- Triage findings: High and Medium must be resolved. Unresolved Lows are logged to
  `backlog.md` under Known Issues.

### 6. Human acceptance test
Run the plain-language steps documented in the requirement file. Confirm the feature
delivers actual value, not just green tests.

### 7. Checkpoint, deliver, harvest & log (`/checkpoint`)
Follow `references/checkpoint.md` and `references/learnings.md`:
1. **Archive delivery:** Move item row from `backlog.md` into `docs/delivered.md`
   with completion date, owner, and PR number.
2. **Update status:** Remove from `## In Flight` in `project-status.md`; update
   `Recently Merged` and `Last updated`.
3. **Harvest learnings:** Prompt: *What did we learn?* Append any speedup, trap, or
   pattern to `docs/learnings.md`.
4. **Log metrics:** Record duration, contributor, model, files changed, and lines `+/-`
   into `docs/project-metrics.md`.
5. **Merge and release:** Merge to `main`, push `origin main`, and delete the remote
   feature branch to release the lock.

---

## Rituals and commands

| Ritual | Command | What it does |
|---|---|---|
| Start | `/start` | Syncs remote, checks in-flight locks, ingests learnings, reports state |
| Kickoff | `/kickoff` | Sets up repo, milestones, backlog, and initial architecture |
| Plan | `/plan` | Prepares requirement and implementation plan with concurrency risk flags |
| Implement | `/implement` | Locks item, creates remote branch, delegates build loop to worker subagent |
| Review | `/review` | Runs independent adversarial subagent review over feature diff |
| Checkpoint | `/checkpoint` | Pre-merge rebase, verify gate, archives delivered item, harvests learnings, logs metrics |
| Metrics | `/metrics` | Displays project velocity, agent contributions, and cost summary |

---

## Artifacts in a multi-agent repository

```
your-project/
  README.md                    what it is, how to run it
  project-status.md            ephemeral state: in-flight matrix, recently merged, next up
  backlog.md                   lean active backlog: Next Up & Open Items by Milestone
  architecture.md              stack, system boundaries, ADR decision log
  .env.example                 secret keys template with dummy values
  docs/
    SETUP.md                   machine setup & secret acquisition guide
    user-journey.md            personas, flows, screens, design tokens
    delivered.md               permanent archive of completed backlog items
    cancelled.md               archive of cancelled items with rationale
    learnings.md               repository playbook: speedups, traps, conventions
    project-metrics.md         effort, velocity, model, and token/cost log
    requirements/BL-XXX.md     specification and acceptance criteria per item
    plans/BL-XXX-plan.md       disposable per-feature implementation plans
  scripts/
    verify.sh                  the gate: lint, build, test, env check
    metrics-summary.sh         velocity and spend reporting dashboard
    scan-secrets.sh            git history secrets scanner
```

Templates for all artifacts reside in `assets/templates/`. Always copy them rather than
inventing new formats.
