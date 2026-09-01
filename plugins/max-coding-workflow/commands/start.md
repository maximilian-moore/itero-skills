---
description: Open a session - sync the repo, read the status and backlog, report where the project is
---

Run the session-start ritual for Max's AI Coding Framework. Do this even if a
SessionStart hook already printed a project state block; the hook only reports, and the
sync and the read-back below are still owed.

Do not start any implementation work during this command. It ends with a question.

## 1. Sync with the remote

```bash
git status
git fetch --all --prune
git log --oneline -10
git status -sb
```

Then decide, and say which you did and why:

- **Working tree clean and behind the upstream:** `git pull --ff-only`. If that fails
  because history diverged, stop and tell the user; do not merge or rebase on your own.
- **Uncommitted changes present:** do not pull. Report what is uncommitted and ask
  whether to stash, commit, or leave it. Losing a user's work at session start is the
  worst possible opening move.
- **No remote configured:** say so once and continue.
- **Ahead of upstream:** report how many commits are unpushed. Do not push.

## 2. Read the repo

Read, in this order, and only what exists:

1. `project-status.md` - where the project is and what the next step is.
2. `backlog.md` - the `Next up` list, plus which items are `ready` and whether
   anything is stuck in `implementation`.
3. The requirement file for the top `Next up` item, if one exists.

If there is no `project-status.md` and no `backlog.md`, this project is not set up yet.
Say so and offer `/kickoff`.

## 3. Check for drift

Three checks, because each one catches a different way a session goes wrong:

- **Stale status.** Compare the newest commit date against the `Last updated` line in
  `project-status.md`. If the repo has moved and the status has not, say so and offer to
  reconstruct the status from `git log` before anything else.
- **Abandoned branch.** If you are not on the main branch, or an item sits in
  `implementation` with no merged PR, report it. Half-finished work from a dead session
  is the most common thing lost between sessions.
- **Backlog and status disagree.** If `project-status.md` says the last merge was
  BL-004 but `backlog.md` does not have BL-004 as `implemented`, one of them is wrong.
  Flag it rather than guessing.

## 4. Report and ask

Two or three lines, in plain language, no jargon:

- Where the project is, in terms of what a person can do with it today.
- What the status file says the next step is.
- Anything that drifted, if it did.

Then ask whether to proceed with that next step. Offer the natural follow-on:
`/plan` to write the plan for an item, `/implement` to build the top `ready` item, or
`/kickoff` if the project is not set up.

Wait for the answer. Do not pick an item and start working.
