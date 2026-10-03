# Concurrency & Multi-Agent Collaboration

When multiple agents or engineers collaborate on a single codebase, coordination
failures occur at the boundaries: branch collisions, lockfile corruption, schema
divergence, and test interference.

This document details the protocols for concurrency management without relying on
centralized servers.

---

## 1. The Distributed Claim Lock

In Git, local branches are invisible across machines. An agent cannot know what another
agent is building unless that claim is published to the remote tracking repository.

### Claiming Protocol:
1. **Remote Inspection:**
   Run `git fetch --all --prune`. Inspect remote branches with `git branch -r`.
   Verify that no remote branch matches `origin/feat/BL-XXX-*`.
2. **Backlog Status Update:**
   In `backlog.md`, set status to `implementation` and record `Owner: <actor-id>`.
3. **Immediate Lock Publication:**
   Create the feature branch using the strict naming standard:
   ```bash
   git checkout -b feat/BL-XXX-<actor-id>-<slug>
   git commit --allow-empty -m "chore(BL-XXX): claim task by <actor-id>"
   git push -u origin feat/BL-XXX-<actor-id>-<slug>
   ```
   The presence of `origin/feat/BL-XXX-...` on the remote is the **distributed mutex**.
   Any other agent checking remote branches will see the lock and must not pick `BL-XXX`.

### Releasing the Lock:
When the feature is merged into `main` during `/checkpoint`, delete both the local
branch and the remote tracking branch:
```bash
git push origin --delete feat/BL-XXX-<actor-id>-<slug>
git branch -d feat/BL-XXX-<actor-id>-<slug>
```
If work is abandoned or blocked, update `backlog.md` back to `ready` (or `cancelled`)
and delete the remote branch.

---

## 2. Stale / Ghost Lock Recovery

If an agent crashes, runs out of quota, or the user closes a session mid-implementation,
an item can remain locked indefinitely.

### Detection in `/start`:
1. Check each item in `project-status.md` under `## In Flight`.
2. Run `git log -1 --format=%ct origin/feat/BL-XXX-...`.
3. If the newest commit on the feature branch is older than **24 hours**:
   - Flag the item to the user as a **Stale Lock**.
   - Output:
     > *"Notice: BL-008 is marked in-flight by agent-claude on branch feat/BL-008-... but has had no commits for 32 hours."*
   - Ask the user to select one:
     - **Resume:** Continue the implementation on that existing branch.
     - **Release:** Reset status in `backlog.md` to `ready`, delete the remote branch, and clear from `In Flight`.
     - **Leave untouched:** Another team member is actively working on it offline.

---

## 3. Parallel Agents on the Same Machine: Git Worktrees

If a human user runs two or more agents simultaneously on the same local clone, running
`git checkout` in the same directory will switch files underneath active compilers and
break running test suites.

### The Worktree Solution:
Instead of cloning the entire repository multiple times, use **Git Worktrees**:
```bash
# In the primary project root, add a worktree for the second agent:
git worktree add ../my-project-worker-2 feat/BL-005-agent2-csv-export

# Direct Agent 2 to operate inside ../my-project-worker-2
```
Each worktree possesses its own working directory and `HEAD` pointer while sharing the
same underlying `.git` storage.

When the work is merged and deleted:
```bash
git worktree remove ../my-project-worker-2
```

---

## 4. Lockfile Thrashing & Dependency Hygiene

When Agent 1 installs package A and Agent 2 installs package B, merging branches causes
severe, unreadable conflicts in `package-lock.json`, `pnpm-lock.yaml`, `poetry.lock`, or
`Cargo.lock`.

### The Anti-Corruption Rule:
**Never attempt text merge resolution on lockfiles.**

During pre-merge rebase in `/checkpoint`:
1. Rebase onto `origin/main`:
   ```bash
   git fetch origin main
   git rebase origin/main
   ```
2. If a lockfile conflict occurs:
   - Accept the upstream version or checkout `main`'s lockfile:
     ```bash
     git checkout --ours package-lock.json # or --theirs depending on rebase state
     ```
   - Re-run the clean installation command of the package manager:
     - Node / npm: `npm install`
     - pnpm: `pnpm install`
     - Python Poetry: `poetry lock --no-update && poetry install`
     - Rust Cargo: `cargo check`
   - Stage the cleanly regenerated lockfile and continue rebase:
     ```bash
     git add package-lock.json
     git rebase --continue
     ```

---

## 5. Database Schema & Migration Collisions

If two concurrent branches create migrations with the same sequence number (e.g.
`0004_add_profile.py` and `0004_add_orders.py`), linear migration histories break.

### Pre-Merge Rebase Check:
1. In the implementation plan, always identify if the item has `Schema Impact: Yes`.
2. Before merging, after rebasing on `origin/main`, inspect the migrations directory:
   - Are there two migrations with the same prefix?
   - Has a newer migration landed from another agent?
3. If a conflict exists, re-index or re-generate your branch's migration to sit cleanly
   at the tip of the sequence.
4. Run the project test suite and verify migration rollback and forward execution.
