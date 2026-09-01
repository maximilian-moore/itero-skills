# Phase 5, step 11: Checkpoint, merge, handoff

A checkpoint is the moment the repository catches up with the conversation. Everything
useful that exists only in this context window gets written down, and then the context
becomes disposable.

This is the step that makes the rest of the process work. Without it, stopping a
session loses knowledge and the next session starts by guessing.

---

## Who owes the update

You do, and immediately. Not the user, not a command they have to remember, not a
cleanup pass later.

The rule is tied to an action *you* perform: **if you merged it, you write the status.**
That works because the trigger is your own behaviour rather than the user's memory. A
process step that depends on a human remembering to type something is a process step
that gets skipped.

## project-status.md

One page. If it grows past a page, you are duplicating something that lives elsewhere,
and rule 5 says pick one home. Git history is the session log. This file is the
current state.

```markdown
# Project status

Last updated: 2026-08-30
Last merged: BL-002 - Save a draft entry (PR #7)

## Where we are
Two sentences. What works today, what a person can actually do with it right now.

## Next step
BL-004 - Export to CSV. Needs an implementation plan.
[One suggested next action, always. Never leave this empty.]

## Open decisions
- Should entries be editable after saving? Undecided since kickoff.
- Hosting: still local only. Decide before BL-009.

## Gotchas
- The dev server needs Node 20. Node 22 breaks the build with a cryptic error
  about a missing loader.
- Tests must run with TZ=UTC or three date tests fail locally.
```

**Next step is never empty.** The user should be able to open this file cold, on any
machine, and know what to do without thinking. That is the whole purpose of the file.

**Gotchas earn their place.** Anything that cost you more than ten minutes to work out
goes here. Future sessions will hit the same wall otherwise, and rediscovering the same
problem is the most expensive thing an AI agent does.

## The merge ritual

In this order. Merging is not one action, it is a sequence, and the sequence is the gate.

1. Verify command passes
2. Subagent review done, findings triaged, High and Medium fixed
3. Human acceptance test written into the requirement file
4. `backlog.md` updated: item to `implemented`, any new `BUG-XXX` rows added
5. `architecture.md` updated if there was architecture impact
6. `project-status.md` updated
7. Commit the doc changes onto the feature branch
8. Merge to main
9. Delete the branch

If step 6 has not happened, step 8 does not happen either. The merge is not finished
until the repo describes itself accurately.

## The handoff note

After merging, before recommending a fresh session, write two or three sentences of
plain-language handoff to the user:

> Merged BL-002. You can now write an entry and it persists across a refresh.
> Next up is BL-004, CSV export, which needs a plan first. One thing to watch: the
> save handler does not yet validate empty titles, that is logged as BUG-003.
> Good moment to start a fresh session.

Then recommend `/clear` or a new session. The reason to give the user: a long context
gets expensive and the model starts drifting from decisions made early on. A fresh
session that reads the status file is more reliable than a tired one that remembers.

Only recommend it once the checkpoint is complete. Recommending a clear with an
unwritten status is how work gets lost.

## Staleness

At the start of every session, compare the last commit date with the `Last updated`
line in `project-status.md`. If commits are newer than the status, the file is lying.

Say so, plainly, and offer to reconstruct it from `git log` before doing anything else.
Do not proceed on a stale status, because every decision after that inherits the wrong
picture of where the project is.

The SessionStart hook flags this automatically in Claude Code. Check it manually
everywhere else.

## Mid-session checkpoints

Not every checkpoint follows a merge. Checkpoint whenever:

- A phase completes (kickoff, architecture, UX)
- A significant decision is made, even if no code changed
- You hit the stuck rule, three failed attempts
- The user says they are stopping for the day

The last one matters most. When a session ends mid-feature, write down what is
half-done, what is on the branch, and what the next move was going to be. Half-finished
work with no note is the single most confusing thing to return to.
