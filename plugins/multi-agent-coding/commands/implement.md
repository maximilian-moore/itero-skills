---
description: Claim and build the top ready backlog item - distributed lock, worker subagent delegation, verify
---

Read `references/concurrency.md` and `references/orchestrator.md`.

Run the Phase 5 build loop for one backlog item in status `ready`.

One PR is one backlog item. This command executes exactly one feature.

## 1. Select and verify unblocked item
Read `backlog.md`. Take the top `ready` item from `Next up` that has all blockers resolved.
- If nothing is `ready`, run `/plan` first.
- If an item is already in `implementation`, check if its remote branch is active.

## 2. Distributed lock verification
```bash
git fetch --all --prune
git branch -r
```
Verify that no remote branch matches `origin/feat/BL-XXX-*`.
If an active branch exists, **it is locked by another agent**. Abort and select the next unblocked item.

## 3. Verify plan
Confirm `docs/plans/BL-XXX-plan.md` exists and was approved.

## 4. Branch, claim, and publish remote lock
```bash
git checkout main && git pull --ff-only origin main
git checkout -b feat/BL-XXX-<actor-id>-<slug>
```
- In `backlog.md`: Set status to `implementation` and record `Owner: <actor-id>`.
- In `project-status.md`: Add row to `## In Flight`.
- Publish the distributed lock immediately:
```bash
git add backlog.md project-status.md
git commit -m "chore(BL-XXX): claim task by <actor-id>"
git push -u origin feat/BL-XXX-<actor-id>-<slug>
```

## 5. Dispatch Worker Subagent
Following `references/orchestrator.md`, dispatch a **Worker Subagent** with:
- Feature requirement: `docs/requirements/BL-XXX.md`
- Implementation plan: `docs/plans/BL-XXX-plan.md`
- Relevant entries from `docs/learnings.md`

The worker writes code and tests together, executes `./scripts/verify.sh` until clean,
and commits its work onto the branch.

*(If your environment lacks subagent support, execute the worker steps in this session
following the fallback in `references/orchestrator.md`.)*

## 6. Review & Checkpoint
Upon worker completion, run `/review` followed by `/checkpoint`.
