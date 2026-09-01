---
name: max-coding-workflow
description: >
  Max's AI Coding Framework - a disciplined, repo-first process for building software
  with an AI coding agent, made for builders who are not professional developers. Covers
  repo and secrets setup, a grilling kickoff interview, backlog and requirement structure,
  architecture decisions with an ADR log, user journey and design handoff, per-requirement
  implementation plans, subagent code review with bug triage, and session checkpointing so
  work survives a cleared context window. Use this skill whenever the user starts a new
  software or app project, resumes an existing one, or says things like "let's build X",
  "new project", "start a session", "where did I leave off", "what should I work on next",
  "implement the next item", "review this PR", "plan this feature", "update the project
  status", or "I want to make this repo public". Also use it whenever
  the user is vibe coding, working in Claude Code on a personal project, or asks how to
  structure an AI-assisted build. Do not skip it for small changes - small changes are
  where the process gets dropped and the repo rots.
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

**2. Nothing merges until all four are true.**
- The verify command passes (lint + build + tests)
- A subagent code review has run and its findings are triaged
- A human acceptance test is written in plain language
- `project-status.md` reflects the change

If any one is missing, the merge has not happened yet.

**3. Security and data loss are never Low.**
A finding that touches secrets, authentication, user data, payments, or data deletion
is at minimum Medium severity, no matter how small the fix looks.

**4. The stuck rule: three strikes, then stop.**
After three failed attempts at the same problem, stop coding. Write what you tried and
what you observed into `project-status.md` under Gotchas, then ask the user how to
proceed. Looping burns tokens and quietly mangles the codebase, and a non-developer
cannot easily tell flailing apart from progress.

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
| 3 | Architecture chosen and justified | `references/architecture.md` | `architecture.md` + first ADR entries |
| 4 | User journey, screens, design tokens | `references/ux-flow.md` | `docs/user-journey.md` + design tool prompt |
| 5 | Build loop, one backlog item at a time | `references/planning.md`, `references/review.md`, `references/checkpoint.md` | Merged PR + updated status + handoff note |
| 6 | Public readiness | `references/security.md` | History scanned, README, LICENSE |

Do not read all the reference files at once. Read the one for the phase you're in.
Loading everything wastes context that the actual work needs.

After every phase, update `project-status.md` and commit. That commit is the
checkpoint that makes the phase survivable.

---

## Phase 5: the build loop in detail

This is the part that repeats. Follow it in order.

**1. Pick the item.** This is `/implement`. Take the top `ready` item from Next up in
`backlog.md`, or ask the user. Only `ready` items get built - an `idea` or a `draft` has
no acceptance tests yet, so there is nothing to build against. Check its `Blocked by`
field; if a blocker is not `implemented`, say so and pick the next one.

**2. Write the implementation plan.** Follow `references/planning.md`. The plan is
per-requirement, never global, because priorities shift and a global plan rots. Save it
to `docs/plans/BL-XXX-plan.md`.

**3. Get approval.** Show the user the plan and wait. Do not start coding on an
unapproved plan. This is the cheapest possible moment to catch a misunderstanding.

**4. Branch.** `git checkout -b feat/BL-XXX-short-slug`. Never work directly on main.
Set the item to `implementation` in `backlog.md` and commit that on the branch. That
status is what lets a future session find work abandoned by a session that died.

**5. Build.** Write the code and the automated tests together, not tests afterwards.
Stay inside the plan's scope. Anything outside it goes to the backlog.

**6. Verify.** Run the verify command. It must exit clean. If it doesn't, fix it before
review. Never ask for review on a red build.

**7. Self-check.** Reread your own diff against the requirement. This is cheap and it
catches real mistakes, but it is not the review, because the model that wrote the code
is the worst judge of whether the approach was right.

**8. Subagent review.** Always. Follow `references/review.md`. The subagent gets a
scoped brief - the diff, the requirement file, `architecture.md`, and the checklist -
and nothing from this conversation. That scoping is the whole point: it removes the
reasoning that led to the design, so the reviewer judges the result instead of
re-agreeing with the process.

**9. Triage in the main context.** Findings come back here, where the full design
discussion is still available. Classify each as High, Medium or Low using the
definitions in `references/review.md`. Fix all High and Medium. Fix Low only if the
fix is small and stays inside files already in the diff. Everything unfixed goes to
the Known issues section of `backlog.md` with an ID.

**10. Write the human acceptance test.** Plain language, numbered steps, no jargon.
The user must be able to confirm the feature actually works without reading code.
Automated tests prove nothing broke. This proves something works.

**11. Merge and checkpoint.** Follow `references/checkpoint.md`. Update
`project-status.md`, move the backlog item to `implemented`, merge to main, then write a
handoff note and recommend the user start a fresh session or `/clear`.

The status update happens *before* the merge is called finished, and you are the one
who owes it, because you are the one who merged.

---

## The backlog states

Six states, in order. Every ritual below reads or writes one of them, which is why the
vocabulary is fixed and small.

`idea` - captured, not thought through.
`draft` - worth building, requirement file being written.
`ready` - requirement and acceptance tests complete, buildable today.
`implementation` - a branch exists and work is in flight.
`implemented` - merged to main.
`cancelled` - dropped for good, kept with a one-line reason why.

`/plan` promotes `idea` to `draft` to `ready`. `/implement` only picks up `ready` and
sets `implementation`. `/checkpoint` sets `implemented`. Full definitions and the
reasoning are in `references/backlog.md`.

## Rituals and shortcuts

Six steps in this process are rituals with their own instructions. In tools that
support slash commands they are available as `/start`, `/kickoff`, `/plan`,
`/implement`, `/review` and `/checkpoint`. Where they are not, the reference files
carry the same instructions.

Either way, run the ritual yourself at the right moment without waiting to be asked.
The user should not have to remember process mechanics while thinking about the
product, and a step that depends on someone typing a command is a step that gets
skipped.

- start - open a session: sync, read status and backlog, report state, ask
- kickoff - Phase 0 to 4 for a new project
- plan - requirement and implementation plan for one backlog item
- implement - build one `ready` item end to end, through to merge
- review - independent review of the current diff
- checkpoint - status update, merge, handoff note

A normal session is `/start`, then either `/plan` or `/implement`, then stop. Two
backlog items in one session is usually one item too many: the second one is built on a
context window already full of the first.

## Running in different tools

The phases, rules and artifacts are the same everywhere. Two things vary:

- **Independent review.** Preferred: a subagent with the scoped brief in
  `references/review.md`. If the tool has no subagents, use the fallback in that file.
  Never skip the step and never let the reviewing pass be the one that wrote the code.
- **Session start.** In Claude Code the plugin registers `hooks/session-start.js`
  automatically, and it stays silent outside framework projects. Everywhere else, run
  the `/start` steps above manually at the start of every session. Never skip them
  because a hook might have run.

Write nothing in this process that assumes a particular model or vendor. The user may
run the same repo through several tools.

---

## The artifacts

```
repo/
  README.md                    what it is, how to run it
  project-status.md            one page, current state + next step
  backlog.md                   index: ID, title, value, effort, status, blocked-by
  architecture.md              stack, structure, and the ADR log
  .env.example                 every secret key, no values
  docs/
    SETUP.md                   how to get each secret, per machine
    user-journey.md            personas, flows, screens, design tokens
    requirements/BL-XXX.md     full requirement + acceptance tests
    plans/BL-XXX-plan.md       disposable implementation plan
  scripts/
    verify.sh                  the gate: lint, build, test
    scan-secrets.sh            history scan before going public
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
