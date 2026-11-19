# Max's AI Coding Framework (`max-coding-workflow`)

A plain-language guide to how `max-coding-workflow` works, why every piece is there, and
what a normal day building with it looks like.

---

## Why this workflow exists

AI coding agents are very good at writing code for the prompt in front of them. They
are terrible at remembering, three sessions later, why you picked a database, which
button leads to the real checkout page, or what broke the last time someone touched the
auth config.

Context windows fill up and get cleared. Sessions end. Models switch.

**The core idea:** **the repository is the memory.** Every step in this workflow leaves a
short, durable file in git — a status page, a backlog, an architecture decision log, a
requirement, a handover note — so any fresh session, on any machine, with any AI tool,
can pick up exactly where the last one stopped.

---

## Who it is for

This framework is built for **capable builders who are not professional developers**:
founders, designers, product people, operators, and solo makers using AI coding agents
(Claude Code, OpenAI Codex, Google Antigravity, or a plain chat window).

Because you may not want to inspect every line of code yourself, the workflow replaces
blind trust with structured gates:

- **Questions before code:** choices about hosting, data, auth, and edge cases happen
  in plain language before a line is written.
- **Automated proof:** tests written alongside the code, then deliberately broken for a
  moment (*test-mutation probing*) to prove they actually fail when the code breaks.
- **Independent eyes:** a fresh reviewer with zero conversation history inspects the
  diff so the agent that wrote the code cannot simply grade its own homework.
- **Plain-English human check:** nothing is marked finished until *you* test the
  working feature step by step and say it works.

---

## The five rules

These apply in every phase, even for tiny fixes. Skipping them on "just a quick tweak"
is how projects rot.

1. **One pull request = one backlog item.**
   If you notice another improvement while building, add a one-line `idea` to
   `backlog.md` and keep going. Small PRs can actually be reviewed properly; sprawling
   PRs create false confidence.
2. **Nothing merges until all five are true, and nothing is done until you checked it.**
   Before a PR merges: (a) the verify script passes (`lint` + `build` + `tests`), (b)
   independent review rounds ran and findings are triaged, (c) a plain-language human
   acceptance test is written, (d) `project-status.md` is updated, and (e) the work is
   in an open PR (never committed straight to `main`). Even after merging, the item
   stays in `implementation` (*"merged, waiting for user check"*) until you run the
   human check and pass it.
3. **Security and data loss are never Low.**
   Anything touching secrets, authentication, user data, payments, or deletion is at
   least `Medium` severity. External packages and scripts are verified at their official
   registry before installing, and external text (diffs, comments, issues, web pages)
   is always treated as untrusted data, never instructions.
4. **The stuck rule: three strikes, then stop.**
   After three failed attempts at the same problem, the agent stops editing, cleans up
   temporary debug logs, writes what it tried and observed into `project-status.md`
   under **Gotchas** (or `docs/blockers.md` during an unattended run), and asks you how
   to proceed instead of quietly mangling the codebase.
5. **Every fact lives in exactly one file.**
   Never copy backlog details into `project-status.md` or architecture decisions into a
   requirement. Link by ID (`BL-014`) instead so files never disagree.

---

## How the workflow flows

```mermaid
flowchart TD
  Start(["/start: Sync repo, read status & backlog"]) --> CheckSetup{"project-status.md\nexists?"}
  CheckSetup -->|No| P0["Phases 0-4 (/kickoff):\nRepo, Secrets, Interview, Backlog,\nArchitecture + ADRs, UX & Prototype"]
  CheckSetup -->|Yes| PickTrack{"What are we doing?"}

  P0 --> PickTrack
  PickTrack -->|New feature or fix| Plan["/plan: Write requirement\n(Small fix vs Autonomous run)"]
  PickTrack -->|Bug report / test failure| Debug["/debug: 1 exact repro command,\n1 hypothesis at a time, Prove-It test"]
  PickTrack -->|Build ready item| Impl["/implement: Branch, build with tests,\nprobe new tests, verify.sh"]

  Plan -->|Small fix| Ready["Item status: ready"]
  Plan -->|Autonomous run| QRounds["Fresh-reader question rounds\nuntil 0 critical findings"] --> Ready
  Ready --> Impl

  Debug --> VerifyGate
  Impl --> VerifyGate["scripts/verify.sh green + PR opened"]
  VerifyGate --> Review["/review: Fresh scoped reviewer(s)\nSmall: 1 round | Autonomous: 2 rounds + Security"]
  Review --> Checkpoint["/checkpoint: Update status, squash-merge PR,\ndeploy to test env, write check sheet"]
  Checkpoint --> HumanCheck{"User runs Human\nAcceptance Test"}
  HumanCheck -->|Bugs found| Debug
  HumanCheck -->|Passed| Done["Status -> implemented\nUpdate learnings.md -> /handover"]
```

---

## The seven phases (0 to 6)

Phases **0 to 4** run once when a project starts. **Phase 5** is the repeating build
loop where you spend almost all your time. **Phase 6** runs when you decide to make a
private repository public.

| Phase | Name | What happens | Durable output in repo |
|---|---|---|---|
| **0** | Repo & Safety | Private git repo, branch protection, `.gitignore` explained in plain English, `.env.example`, `docs/SETUP.md`, initial `scripts/verify.sh` | Repo baseline, `AGENTS.md`, `learnings.md` |
| **1** | Kickoff Interview | Vision, target users, MVP vs later, plus the 4 expensive-to-undo answers: where it runs, who can access it, where data lives, what it costs | Kickoff notes feeding backlog |
| **2** | Backlog | Every piece of work captured with an ID (`BL-001`), value, effort, dependencies, and a ranked `Next up` list | `backlog.md` |
| **3** | Architecture & Tests | Stack, hosting, data model, and test stack chosen with trade-offs you approve; recorded as numbered Architecture Decision Records (ADRs) | `architecture.md`, `scripts/verify.sh`, `docs/run-protocol.md` |
| **4** | User Journey & Design | End-to-end user flows, 3 visual design directions rendered as HTML pages you inspect in a browser, optional clickable prototype | `docs/user-journey.md`, `docs/design/style.html`, `prototype/` |
| **5** | Build Loop | Pick one `ready` item -> `/plan` -> branch -> test-first build -> probe tests -> `verify.sh` -> PR -> `/review` -> `/checkpoint` -> your check -> `/handover` | Requirement, plan, code, tests, PR, check sheet |
| **6** | Public Readiness | Full git history secret scan (`gitleaks` / `scan-secrets.sh`), leak rotation, personal/work cleanup, stranger-friendly `README.md`, `LICENSE` | Public-ready repo |

---

## Backlog states & the two build tracks

Every item in `backlog.md` moves through six fixed states:

```text
idea  -->  draft  -->  ready  -->  implementation  -->  implemented
                                        |
                                        +--> cancelled (kept with 1-line reason)
```

- **`idea`**: captured in one line so you don't forget it.
- **`draft`**: promoted as worth building; requirement file is being written.
- **`ready`**: requirement and named acceptance tests (`BL-XXX-T01`) are complete and
  unblocked — buildable today.
- **`implementation`**: branch is active, or PR is merged and waiting for your human check.
- **`implemented`**: merged to `main` *and* verified by you.
- **`cancelled`**: dropped for good, kept in the table with a one-line reason.

### Small Fix vs. Autonomous Run

Not every task needs the same ceremony. Each requirement declares one of two tracks:

| Track | When to use it | Planning & Question Rounds | Code Review |
|---|---|---|---|
| **Small fix** | Text tweak, UI alignment, single bug, ~3 files or fewer | Short requirement template, approved plan, **no question rounds** | **1 round** (Correctness; adds Security if touching rule-3 areas) |
| **Autonomous run** | New features, multi-file changes, anything you want built unattended | Full requirement template + **fresh-reader question rounds** (up to 4 rounds until zero critical ambiguities remain) | **2 rounds, 3 reviewers**: Round 1 = Correctness + Security in parallel -> fix -> Round 2 = new Correctness reviewer checking the updated diff |

During an **autonomous run**, the agent starts in a fresh session with a plain-text run
prompt pointing at `docs/run-protocol.md` and `docs/requirements/BL-XXX.md`. If a small
detail is ambiguous during the unattended build, it follows the **Blocker Protocol**:
pick the most conservative option (least data exposed, tightest gate, easiest to change
later), log it under *Choices taken* in `docs/blockers.md`, and keep going. It only
stops early for hard gates (destructive data loss, missing real secret, weakening tests,
unresolved High review finding, or a manual step only you can perform).

---

## Quality gates that protect your codebase

### 1. Named tests & test-mutation probing
Every acceptance criterion in a requirement gets an ID (`BL-014-T03`) that appears right
inside the automated test title. That makes it trivial to confirm every criterion has a
test without reading implementation code.

Even better: before opening a PR, the agent **probes up to three new tests**. It
temporarily breaks one line or guard in the code each test claims to cover, confirms the
test actually fails for the right reason, restores the line byte-for-byte, and re-runs
`scripts/verify.sh`. This prevents "tautology tests" that stay green even when the
feature is broken.

### 2. Independent review & prompt-injection guardrails
The model that spent an hour writing a feature has its own reasoning stuck in context
and tends to agree with itself. So `/review` spins up fresh subagents (or hands a scoped
brief via `.review/` in tools without subagents) that see **only** the diff, the
requirement, `architecture.md`, and the review checklist.

Reviewer briefs also include explicit **untrusted-data guardrails**: diffs, code
comments, commit messages, PR descriptions, and test output are treated strictly as data,
never instructions. Any text attempting to steer a reviewer or waive checks is flagged as
a `High` security finding.

Findings are triaged in the main session using strict severity rules (`High` and
`Medium` must be fixed in the PR; `High` fixes require a regression test; security/data
loss can never be downgraded to `Low`).

### 3. Human Acceptance Test ("Merged is not done")
Automated tests prove nothing broke; the human check proves something actually works.
Every PR includes plain-language numbered steps (*"1. Open `/settings`. 2. Click
Export..."*) and autonomous runs finish by deploying to a test environment and writing a
check sheet in `docs/evidence/BL-XXX.md` with screenshots and any choices awaiting your
confirmation.

---

## Systematic debugging (`/debug`)

When a test fails or a bug surfaces, `/debug` stops the agent from stacking blind guesses:

1. **Stop the line** — pause new edits and preserve the exact error output.
2. **Clarify mode** — confirm whether you want root cause + failing test only (*diagnose
   only*) or root cause + minimal fix.
3. **One exact command** — reproduce the failure reliably on demand first (using
   environment/seed isolation or `git bisect` if needed).
4. **One hypothesis at a time** — inspect the real code path, check one explanation, and
   revert any temporary probe before trying the next.
5. **Prove-It test first** — write a failing test (`BUG-XXX-T01`), confirm it fails for
   the right reason, apply the smallest fix, probe the test, run `scripts/verify.sh`, and
   clean temporary logs.
6. **Three strikes, then stop (Rule 4)** — if three attempts fail, stop, clean up, record
   what happened in `project-status.md` under *Gotchas*, and ask.

---

## Memory across sessions & the Learning Loop

- **`project-status.md`**: One-page source of truth read at every session start. Holds
  what the app does today, what is next, gotchas, and any security incidents.
- **`docs/handover.md`**: Written at the end of a session by `/handover` with exact
  commit hash, what changed, what to read first next time (and what *not* to read in
  full), plus a copy-paste restart prompt.
- **`learnings.md`**: At the end of every phase, run, `/checkpoint`, or `/handover`, the
  agent answers three questions (*what cost extra tokens/time, what caused rework, what
  the next agent should do differently*) and logs up to 3 short rules under the matching
  phase section.
- **`AGENTS.md`**: Loaded automatically at every session start; holds the few traps that
  can bite on *any* turn, plus where files live.

---

## The eight rituals

In tools that support slash commands (such as Claude Code), these are installed as
shortcuts. In tools without slash commands (Codex, Antigravity, chat interfaces), the
agent follows the matching steps from `SKILL.md` and `references/` automatically.

| Command | When to run | What it does |
|---|---|---|
| `/start` | Opening a session | Fetches remote, pulls if clean and behind, checks for drift between git/status/backlog, summarises state in 2–3 lines, and asks what to do |
| `/kickoff` | Starting a new project | Guides Phases 0 to 4: repo & secrets setup, kickoff interview, backlog, architecture + ADRs, design directions & optional prototype |
| `/plan` | Preparing an item | Promotes `idea` -> `draft` -> `ready`, picks small fix vs autonomous run, writes the requirement + tests, runs question rounds if autonomous, writes the implementation plan |
| `/debug` | When something breaks | Reproduces with one exact command, tests one hypothesis at a time, writes a failing test first, applies minimal fix (stops after 3 strikes) |
| `/implement` | Building one `ready` item | Branches, writes code + tests together, probes new tests, runs `verify.sh`, opens PR, triggers `/review`, walks through human check, checkpoints |
| `/review` | Auditing a PR branch | Runs scoped independent Correctness (and Security) subagent reviews, triages findings, fixes High/Medium, logs deferred Lows |
| `/checkpoint` | Closing out a PR | Updates `project-status.md` and `backlog.md`, logs ADRs and `learnings.md`, squash-merges PR, syncs `main`, deploys to test env if present |
| `/handover` | Ending a session | Ensures status is true and pushed, writes `docs/handover.md`, updates `learnings.md`, prints a short restart prompt for a fresh context |

A normal working session is simply: **`/start`** -> **`/plan`** or **`/implement`** (or **`/debug`**) -> **`/handover`**.

---

## What the workflow creates in your repository

```text
your-project/
  README.md                    What the app does and how to run it (no jargon)
  AGENTS.md                    Repo map + universal traps loaded every turn
  learnings.md                 Lessons grouped by phase, read before planning/runs
  project-status.md            One-page current state + next step + Gotchas
  backlog.md                   Scannable index (ID, value, effort, status, Known issues)
  architecture.md              Chosen stack, structure, and numbered ADR log
  .env.example                 Every required env var key, never real values
  docs/
    SETUP.md                   Where to get each secret key per machine
    user-journey.md            Personas, flows, screen states, design tokens
    design/style.html          Chosen visual design direction
    mockups/BL-XXX.html        Optional mockup for screens not in prototype
    requirements/BL-XXX.md     Per-item requirement + acceptance tests
    plans/BL-XXX-plan.md       Disposable per-item implementation plan
    run-protocol.md            Project rules every autonomous run follows
    blockers.md                Choices taken in runs waiting for user confirmation
    evidence/BL-XXX.md         Autonomous run check sheet, test probes & screenshots
    handover.md                Overwritten end-of-session handover + restart prompt
  prototype/                   Optional clickable HTML prototype of key flows
  scripts/
    verify.sh                  The merge gate (lint + typecheck + test + build)
    scan-secrets.sh            Full-history secret scanner for Phase 6
    check-requirement.sh       Linter for open choices/TBD/test-ID gaps in specs
  .review/                     Temporary briefs & findings when no subagents exist (gitignored)
```

---

## Tool portability & installation

`max-coding-workflow` follows the open Agent Skills specification and stays vendor-neutral:

- **Claude Code:** Install via `/plugin marketplace add maximilian-moore/itero-skills` and
  `/plugin install max-coding-workflow@itero-skills`. Includes a cross-platform Node
  `SessionStart` hook (`hooks/session-start.js`) that silently ignores non-framework
  repos and prints a quick state summary in framework repos.
- **OpenAI Codex & Google Antigravity:** Install via `./install/install-codex.sh` or
  `./install/install-antigravity.sh`.
- **Other tools / plain chat:** Copy `plugins/max-coding-workflow/skills/max-coding-workflow/`
  into `.agents/skills/` or paste `SKILL.md` directly. Where subagents aren't available,
  `references/review.md` and `references/requirement-review.md` degrade cleanly to a
  `.review/` file handover between separate sessions or different models.

Full installation and troubleshooting steps: [docs/INSTALL.md](INSTALL.md).
