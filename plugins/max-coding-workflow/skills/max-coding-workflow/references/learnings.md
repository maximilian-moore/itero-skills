# The learning loop

Every phase, run and session ends by writing down what would make the next one better:
fewer bugs and less rework, and fewer tokens for the same quality. The next agent reads
it before it plans, so the lesson changes the plan instead of being rediscovered
halfway through the build.

Two goals, in this order: **quality** first, then **efficiency**. A learning that saves
tokens by skipping a check is not a learning; it is a shortcut that will cost more
later.

---

## Two homes

**`learnings.md`** - at the repository root, from `assets/templates/learnings.md`. The
main home. One section per phase: Planning, Design, Build, Testing, Review, Deploy,
Process. It is read at the moments below, not in every session, so it costs nothing
in between.

**`AGENTS.md`** - only for the few learnings that can bite in any turn, whatever the
phase: a framework version that differs from what agents expect, a command that needs
special permission, a file never to read in full. `AGENTS.md` is loaded automatically
by most coding tools at every session start, so a trap listed there is known before the
first turn. That is also its cost: every line is paid in every session. Keep its
learnings section to about five lines.

The test: could this trap hit before the agent has read `learnings.md`? Then it goes to
`AGENTS.md`. Otherwise it goes to its phase section in `learnings.md`. When a learning
in `learnings.md` turns out to matter in every run, move it.

**Not here:** `project-status.md` keeps a Gotchas section for traps that are temporary
and tied to the current state ("test X is flaky until BUG-006 is fixed"). When the
state changes they go away. A lasting lesson belongs in `learnings.md`.

## When to read

Read only the sections that fit what you are about to do, by heading. Never the whole
file when one section is enough.

- **`/plan`, before writing the requirement:** Planning, Design, Build, Testing. Carry
  every learning that applies into the requirement - as a decision in section 4, an
  edge case in section 8, a stop condition in section 12 - or into the plan. A
  learning in the requirement reaches the build agent without it having to read this
  file.
- **The start of an autonomous run:** Build, Testing, Review, Deploy, as step 1 of
  `docs/run-protocol.md` says.
- **The start of a kickoff phase:** that phase's section, if the file exists yet.

## When to write

Automatically, without being asked, at the end of:

- each phase of the kickoff
- the question rounds of an item
- each autonomous run, before its final message
- every `/checkpoint` and every `/handover`

Answer three questions about the work just finished:

1. **What cost extra tokens or time?** A large file read in full, a search repeated,
   a wrong path followed, a test suite run more often than needed.
2. **What caused a bug, a review finding or rework?** A missed edge case, a wrong
   assumption about the code, a rule the requirement did not state.
3. **What should the next agent do differently?** The instruction that would have
   prevented 1 and 2.

Write at most three entries per run. Most runs teach one thing worth keeping, and some
teach nothing - then write nothing. An entry that only says the work went fine is
noise.

## How to write an entry

One instruction, the reason, and the date:

```markdown
- Read `prototype/index.html` only by its `SCREEN:` markers; it is 340 KB and a full
  read costs more than the whole build step. (2026-10-19)
- Write a requirement only when the code it builds on exists; most question-round
  findings were mismatches with code that changed after the file was written.
  (2026-10-22)
```

- **Imperative and specific.** "Run the maker tests with `--workers=1`", not "be
  careful with parallel tests".
- **With the reason**, so the next agent can tell when the rule does not apply.
- **Merged, not appended.** If an entry on the same subject exists, sharpen it instead
  of adding a second one.
- **Nothing secret.** No keys, passwords, personal data or internal addresses. The file
  is committed.

## Keeping it small

A learnings file that grows without limit becomes the large file nobody should read in
full. Keep `learnings.md` below about 8 KB. When an entry would push it over:

1. Delete entries that no longer apply - the code they warned about is gone, or the
   rule became a test or a script that enforces it.
2. Merge entries that say the same thing.
3. Only then add the new one.

A learning that a script or test can enforce is better as that script or test: it
cannot be forgotten. Note the move in the commit message and delete the entry.

## Process learnings

The Process section holds lessons about the workflow itself rather than this project:
"question rounds found nothing new after round 3", "the security reviewer caught what
correctness missed". They help the next project too. Tell the user when one is added,
so they can carry it back into this skill.
