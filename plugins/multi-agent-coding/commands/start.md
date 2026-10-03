---
description: Open a multi-agent session - sync remote, inspect in-flight claims, ingest learnings, report state
---

Run the multi-agent session-start ritual. Do this at the start of every session before
taking any other action.

Do not start any implementation work during this command. It ends with a question.

## 1. Sync with the remote

```bash
git status
git fetch --all --prune
git branch -r
git log --oneline -10
git status -sb
```

- **Working tree clean and behind upstream:** `git pull --ff-only`.
- **Uncommitted changes present:** Do not pull. Report what is uncommitted and ask whether
  to stash, commit, or discard. Never risk overwriting work.
- **No upstream or no remote:** Report once and continue.

## 2. Read the repo

Read, in this order:
1. `project-status.md` - Active in-flight matrix, recently merged items, current state.
2. `backlog.md` - Next up list and open items by milestone.
3. `docs/learnings.md` - Speedups, framework traps, and testing shortcuts.

If `project-status.md` and `backlog.md` do not exist, this repo is uninitialized. Offer `/kickoff`.

## 3. Scan in-flight tasks & detect stale locks

Check each item listed under `## In Flight` in `project-status.md`:
- Check its remote branch: `git log -1 --format=%ct origin/feat/BL-XXX-...`
- If the newest commit is older than 24 hours, flag it as a **Stale Lock** and ask the
  user whether to resume it, release it back to `ready`, or leave it alone.

## 4. Check for drift

- **Stale status:** Is the newest commit on `main` newer than `Last updated` in `project-status.md`?
- **Ghost branch:** Does an item sit in `implementation` in `backlog.md` with no branch on `origin`?
- Reconcile before starting work.

## 5. Report and ask

State back to the user in 2-3 lines:
- Where the project is (what works today).
- Who is currently working on what (`In Flight` items and branches).
- The top unblocked item in `Next up` and any relevant repo learning.
Then ask whether to proceed.
