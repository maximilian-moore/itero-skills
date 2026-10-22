---
name: max-coding-workflow
description: >
  Max's AI Coding Framework - a repo-first process for building software with an AI
  coding agent, for builders who are not professional developers. Covers repo and
  secrets setup, a kickoff interview, backlog and requirements, architecture with an
  ADR log, user journey and design, per-item plans, independent code review, and
  checkpoints that survive a cleared context. Use it when the user starts or resumes a
  software project, or says "let's build X", "new project", "start a session", "where
  did I leave off", "what next", "implement the next item", "plan this feature",
  "review this PR", "update the status" or "make this repo public". Also use it for
  vibe coding or structuring an AI-assisted build. Do not skip it for small changes -
  that is where the process gets dropped.
---

# Max's AI Coding Framework

A process for building real software with an AI agent without ending up with an
undocumented, untested pile of code you're afraid to touch.

The core idea: **the repository is the memory.** Context windows die, sessions end,
and models forget. Files in git do not. Every phase in this process ends by writing
something durable to the repo, so any future session, on any machine, can pick up
exactly where the last one stopped.

---

## The five rules

These apply in every phase. They are not suggestions, and they exist because each
one prevents a specific failure that is expensive to undo.

**1. One PR = one backlog item.**
When you notice something else worth fixing, add it to the backlog. Do not put it in
the current diff. Sprawling PRs cannot be reviewed properly, and a bad review is worse
than no review because it creates false confidence.

**2. Nothing merges until all five are true, and nothing is done until the user checked it.**
- The verify command passes (lint + build + tests)
- The independent review rounds for the item's kind have run, and their findings are
  triaged: one round for a small fix, two rounds plus a security review for an
  autonomous run (`references/review.md`)
- A human acceptance test is written in plain language
- `project-status.md` reflects the change
- The work sits in an open pull request, and it merges through that pull request

If any one is missing, the merge has not happened yet. Nothing is merged into main
locally and pushed; main only moves through a merged pull request.

Merged is not done. An item moves to `implemented` only when the user has run the human
acceptance test and it passed. Until then it stays `implementation`, with the note
"merged, waiting for user check".

**3. Security and data loss are never Low.**
A finding that touches secrets, authentication, user data, payments, or data deletion
is at minimum Medium severity, no matter how small the fix looks.

**4. The stuck rule: three strikes, then stop.**
After three failed attempts at the same problem, stop coding. Write what you tried and
what you observed into `project-status.md` under Gotchas, then ask the user how to
proceed. Looping burns tokens and quietly mangles the codebase, and a non-developer
cannot easily tell flailing apart from progress. In an autonomous run, stop that part
rather than the run: log it in `docs/blockers.md` and continue with what does not
depend on it (`references/autonomous-run.md`).

**5. Every fact lives in exactly one file.**
Do not copy backlog detail into the status file, or architecture decisions into a
requirement. Duplicated facts drift apart, and once two files disagree the user stops
trusting both. Link by ID instead.

---

## Every session starts the same way

This is the `/start` ritual. Run it before anything else, whether or not the user typed
the command:

1. `git status`, `git fetch --all --prune`, `git log --oneline -10`. Know what branch
   you're on, what happened last, and whether the remote has moved.
2. If the tree is clean and the branch is behind, `git pull --ff-only`. If there are
   uncommitted changes, do not pull - report them and ask. Never open a session by
   putting the user's work at risk.
3. Read `project-status.md` and the `Next up` list in `backlog.md`. If neither exists,
   this is Phase 0.
4. Check for drift three ways: is the newest commit newer than the status file's
   `Last updated` line; is an item stuck in `implementation` with no merged PR; do the
   status file and the backlog disagree about the last merge. Say so before doing
   anything else.
5. State back to the user in two or three lines: where the project is, and what the
   next step is. Then ask whether to proceed.

A SessionStart hook does steps 1, 3 and part of 4 automatically where it is installed.
Do the rest regardless, and never assume the hook ran - it is Claude Code only, and it
stays silent in repositories that are not framework projects.

---

## The phases

Phases 0 to 4 happen once, at the start of a project. Phase 5 is the loop you spend
almost all your time in. Phase 6 happens when the user wants to publish.

| Phase | What happens | Read this | Ends with |
|---|---|---|---|
| 0 | Repo, .gitignore, secrets, verify command | `references/security.md` | Repo initialised, secrets explained to the user |
| 1 | Kickoff interview - vision, users, constraints | `references/kickoff.md` | Feature list + the four retrofit answers |
| 2 | Backlog built with IDs, value, effort, dependencies | `references/backlog.md` | `backlog.md` + ranked Next up list |
| 3 | Architecture and test stack chosen and justified | `references/architecture.md`, `references/testing.md` | `architecture.md` + first ADR entries, test stack in verify |
| 4 | User journey, three design directions, prototype | `references/ux-flow.md` | `docs/user-journey.md` + chosen direction and tokens + optional prototype |
| 5 | Build loop, one backlog item at a time | `references/planning.md`, `references/requirement-review.md`, `references/autonomous-run.md`, `references/review.md`, `references/checkpoint.md` | Merged PR + updated status + handoff note |
| 6 | Public readiness | `references/security.md` | History scanned, README, LICENSE |

Do not read all the reference files at once. Read the one for the phase you're in.
Loading everything wastes context that the actual work needs.

After every phase, update `project-status.md`, write what the phase taught into
`learnings.md`, and commit. That commit is the checkpoint that makes the phase
survivable.

## The learning loop

Every phase, run, `/checkpoint` and `/handover` ends by answering three questions: what
cost extra tokens or time, what caused a bug or rework, and what the next agent should
do differently. The answers - at most three short instructions, each with its reason -
go into the matching phase section of `learnings.md`. The next agent reads the sections
that fit before it plans, so the lesson shapes the requirement instead of being
rediscovered in the build. The few traps that can hit in any turn go into `AGENTS.md`
instead, which tools load at every session start. Quality first, then fewer tokens;
never fewer tokens at the cost of a check. Details in `references/learnings.md`.

---

## Phase 5: the build loop in detail

This is the part that repeats. Follow it in order.

An autonomous item follows the same loop, run unattended: the approved requirement
replaces the plan approval in step 3, missing details follow the blocker protocol
instead of a question, and the run ends with merge, deploy and a check sheet for the
user. How to start and run one is in `references/autonomous-run.md`. A small fix
follows the loop below with one review round.

**1. Pick the item.** This is `/implement`. Take the top `ready` item from Next up in
`backlog.md`, or ask the user. Only `ready` items get built - an `idea` or a `draft` has
no acceptance tests yet, so there is nothing to build against. Check its `Blocked by`
field; if a blocker is not `implemented`, say so and pick the next one.

**2. Write the implementation plan.** Follow `references/planning.md`. The plan is
per-requirement, never global, because priorities shift and a global plan rots. Save it
to `docs/plans/BL-XXX-plan.md`.

**3. Get approval.** Show the user the plan and wait. Do not start coding on an
unapproved plan. This is the cheapest possible moment to catch a misunderstanding. For
an autonomous run that moment came earlier: the user approved the requirement before
it became `ready`, so the run writes the plan and continues.

**4. Branch.** `git checkout -b feat/BL-XXX-short-slug`. Never work directly on main.
Set the item to `implementation` in `backlog.md` and commit that on the branch. That
status is what lets a future session find work abandoned by a session that died.

**5. Build.** Write the code and the automated tests together, not tests afterwards.
Each named test in the requirement (`BL-XXX-T01`) carries its ID in the test title. For
a bug, the failing test comes first. Never weaken, skip or delete a test to get to
green; see `references/testing.md`. Stay inside the plan's scope. Anything outside it
goes to the backlog.

**6. Verify.** Run the verify command. It must exit clean. If it doesn't, fix it before
review. Never ask for review on a red build.

**7. Self-check.** Reread your own diff against the requirement. This is cheap and it
catches real mistakes, but it is not the review, because the model that wrote the code
is the worst judge of whether the approach was right.

**8. Open the pull request.** Push the branch and open a pull request against main
(`gh pr create`). Title: `BL-XXX: <title>`. The body links the requirement file and
says what changed. From here on, every fix is a commit on this branch, pushed, so
the pull request always shows the current state.

**9. Review round 1, then fix.** Follow `references/review.md`. A subagent gets a
scoped brief - the diff, the requirement file, `architecture.md`, and the checklist -
and nothing from this conversation. That scoping is the whole point: it removes the
reasoning that led to the design, so the reviewer judges the result instead of
re-agreeing with the process. For an autonomous run, a second subagent reviews security
in parallel. Triage the findings here in the main context, where the design discussion
is still available. Classify each as High, Medium or Low using the definitions in
`references/review.md`. Fix all High and Medium, each High with a test. Fix Low only
if the fix is small and stays inside files already in the diff. Run verify, commit,
push. A small fix stops here.

**10. Review round 2, then fix.** Autonomous runs only, always, even when round 1 found
little. A new subagent, with the correctness brief and the updated diff, checks that
the fixes do what they claim. It should find no High. Fix all Medium and the easy
Lows; a High means fix, test, and a short review of only that fix, and if it is still
open, stop and ask the user (rule 4). Everything unfixed goes to the Known issues
section of `backlog.md` with an ID.

**11. Write the human acceptance test.** Plain language, numbered steps, no jargon.
The user must be able to confirm the feature actually works without reading code.
Automated tests prove nothing broke. This proves something works.

**12. Merge and checkpoint.** Follow `references/checkpoint.md`. Update
`project-status.md`, note "merged, waiting for user check" on the backlog item, commit
and push those docs to the branch, then merge the pull request
(`gh pr merge --squash --delete-branch`), switch to main and pull. Deploy to the test
environment if there is one. Then the user runs the human acceptance test: passed
moves the item to `implemented`; bugs become small fixes and the check repeats. Then
run the handover (`references/handover.md`) and recommend the user start a fresh
session or `/clear`.

The status update happens *before* the merge is called finished, and you are the one
who owes it, because you are the one who merged.

---

## The backlog states

Six states, in order. Every ritual below reads or writes one of them, which is why the
vocabulary is fixed and small.

`idea` - captured, not thought through.
`draft` - worth building, requirement file being written.
`ready` - requirement and acceptance tests complete, buildable today. For an
autonomous run, the question rounds have also ended with no critical finding.
`implementation` - a branch exists and work is in flight, or it is merged and waiting
for the user's check.
`implemented` - merged to main and checked by the user.
`cancelled` - dropped for good, kept with a one-line reason why.

`/plan` promotes `idea` to `draft` to `ready`. `/implement` only picks up `ready` and
sets `implementation`. `/checkpoint` sets `implemented` once the user's check passed. Full definitions and the
reasoning are in `references/backlog.md`.

Every item is one of two kinds, and the kind sets how much planning it gets. A **small
fix** - one text, one alignment, one bug, about three files or fewer - gets a short
requirement and no question rounds. An **autonomous run** - everything else - gets a
full requirement that an agent can build from alone, for hours, without asking, and
fresh-reader question rounds check that before it is `ready`. When unsure, it is an
autonomous run. Details in `references/planning.md` and
`references/requirement-review.md`.

## Rituals and shortcuts

Seven steps in this process are rituals with their own instructions. In tools that
support slash commands they are available as `/start`, `/kickoff`, `/plan`,
`/implement`, `/review`, `/checkpoint` and `/handover`. Where they are not, the reference files
carry the same instructions.

Either way, run the ritual yourself at the right moment without waiting to be asked.
The user should not have to remember process mechanics while thinking about the
product, and a step that depends on someone typing a command is a step that gets
skipped.

- start - open a session: sync, read status and backlog, report state, ask
- kickoff - Phase 0 to 4 for a new project
- plan - requirement, question rounds and implementation plan for one backlog item
- implement - build one `ready` item end to end, through to merge and the user's check
- review - the independent review rounds for the item's kind, each followed by fixes
- checkpoint - status update, merge the pull request, sync with GitHub
- handover - end a session: status true and pushed, `docs/handover.md` written, a short
  restart prompt printed for the next session

A normal session is `/start`, then either `/plan` or `/implement`, then `/handover`. Two
backlog items in one session is usually one item too many: the second one is built on a
context window already full of the first.

## Running in different tools

The phases, rules and artifacts are the same everywhere. Two things vary:

- **Independent review and question rounds.** Preferred: a subagent with the scoped
  brief in `references/review.md` or `references/requirement-review.md`; a cheaper
  model is fine for the question rounds. If the tool has no subagents, hand the brief
  to a second agent through a file in `.review/`, as described in
  `references/requirement-review.md`. Never skip the step and never let the reviewing
  pass be the one that wrote the code or the requirement.
- **Session start.** In Claude Code the plugin registers `hooks/session-start.js`
  automatically, and it stays silent outside framework projects. Everywhere else, run
  the `/start` steps above manually at the start of every session. Never skip them
  because a hook might have run.

- **Pull requests.** Preferred: the `gh` CLI. Without it, push the branch and give the
  user the pull request link to open and merge in the browser. If the repository has
  no remote yet, set one up in Phase 0; the pull request is not optional.

Write nothing in this process that assumes a particular model or vendor. The user may
run the same repo through several tools.

---

## The artifacts

```
repo/
  README.md                    what it is, how to run it
  AGENTS.md                    where things live, plus traps that hit in any turn
  learnings.md                 lessons per phase, read before planning and runs
  project-status.md            one page, current state + next step
  backlog.md                   index: ID, title, value, effort, status, blocked-by
  architecture.md              stack, structure, and the ADR log
  .env.example                 every secret key, no values
  docs/
    SETUP.md                   how to get each secret, per machine
    user-journey.md            personas, flows, screens, design tokens
    design/style.html          the chosen design direction, as a page
    mockups/BL-XXX.html        mockup for an item's screens the prototype lacks, optional
    requirements/BL-XXX.md     full requirement + acceptance tests (or the short small-fix form)
    plans/BL-XXX-plan.md       disposable implementation plan
    run-protocol.md            the rules every autonomous run follows
    blockers.md                choices taken in runs, waiting for the user
    evidence/BL-XXX.md         check sheet after a run: in, out, screenshots, result
    handover.md                end-of-session handover and restart prompt, overwritten
  prototype/                   clickable prototype of the key flows, optional
  scripts/
    verify.sh                  the gate: lint, build, test
    scan-secrets.sh            history scan before going public
    check-requirement.sh       warns about open choices and gaps in requirement files
  .review/                     briefs and findings for fresh readers, gitignored
  .claude/
    settings.json              project settings, if the project needs any
```

Templates for all of these are in `assets/templates/`. Copy them, don't invent new
shapes, so that every project the user builds looks the same and a fresh session
recognises the structure immediately.

---

## Tone with the user

The user is a capable builder who is not a professional developer. That means:

- Explain the *why* behind a technical recommendation in one sentence, not three
  paragraphs, and not zero.
- Never use jargon in acceptance tests, setup instructions, or the README.
- When there is a real decision to make, present the options with a recommendation
  and the reason for it, then let the user overrule you. Do not silently decide
  architecture on their behalf.
- Say when you are uncertain. A confident wrong answer about hosting or auth costs
  a weekend to unwind.
