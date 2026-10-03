# Phase 5: Checkpoint, Merge & Delivery Ritual

In a multi-agent repository, merging is never a single `git merge` command.
It is an atomic **verification gate** that harmonizes concurrent work, clears active
locks, archives shipped features, captures institutional knowledge, and records
velocity metrics.

The Orchestrator is responsible for executing this sequence in exact order.

---

## 1. The Multi-Agent Merge Sequence

Execute these steps strictly in order:

### Step 1: Upstream Rebase
Ensure your branch incorporates any work merged by other agents while you were building:
```bash
git fetch origin main
git rebase origin/main
```
If merge conflicts arise, resolve them cleanly.

### Step 2: Lockfile & Migration Validation
- If dependencies changed on your branch or upstream, **never text-merge lockfiles**.
  Run clean install (`npm install`, `pnpm install`, `poetry lock`) to regenerate
  deterministically.
- If database migrations exist, confirm migration file numbering remains strictly
  sequential. Re-index if another agent merged a migration with the same sequence.

### Step 3: Verify Gate
Run the project verification script:
```bash
./scripts/verify.sh
```
It must pass completely (lint, build, automated unit/integration tests, secret checks).
Never proceed to review or merge on a red build.

### Step 4: Subagent Adversarial Review
Execute the review ritual (see `references/review.md`).
- Fix all High and Medium findings.
- Fix Low only if minor and isolated.
- Unfixed Lows are logged to `backlog.md` under Known Issues.

### Step 5: Human Acceptance Test
Execute the plain-language steps documented in the requirement file. Confirm the feature
behaves as expected from a user's perspective.

### Step 6: Archive Delivery
1. Delete the item from the `## Open Items` table and `## In Flight` in `backlog.md`.
2. Append the item to `docs/delivered.md` with:
   - ID & Title
   - Milestone
   - Owner / Agent ID
   - Merge Date
   - PR / Commit ID
   - Link to requirement file: `[BL-XXX](requirements/BL-XXX.md)`

### Step 7: Update Project Status
In `project-status.md`:
- Remove the item from `## In Flight`.
- Update `Last updated: YYYY-MM-DD`.
- Add to `Recently Merged` (keep the last 3-5 items).
- Update `What works today` with two concise sentences.
- Ensure `Next up` points to the next unblocked ready item.

### Step 8: Continuous Knowledge Harvest
Prompt the session and inspect the diff against the four learning questions (see
`references/learnings.md`):
- *Did anything fail repeatedly or cost >10 minutes?*
- *Was a dev/test speedup or shortcut discovered?*
- *Was an undocumented trap or edge case identified?*
- *Was a new reusable pattern introduced?*

If yes, append a concise bullet with domain tag to `docs/learnings.md`.

### Step 9: Log Velocity & Cost Metrics
Extract git stats and duration, and append a row to `docs/project-metrics.md`:
- Date, Item ID, Title, Contributor/Agent ID, Model name, Duration (mins), Files,
  Lines `+/-`, Tests added, and Estimated tokens/cost.

### Step 10: Commit, Merge & Release Lock
```bash
# 1. Commit all documentation, status, learning, and metric changes to the branch
git add .
git commit -m "docs(checkpoint): deliver BL-XXX, update status and learnings"

# 2. Fast-forward merge to main
git checkout main
git pull --ff-only origin main
git merge --ff-only feat/BL-XXX-<owner>-<slug>
git push origin main

# 3. Release distributed lock by deleting local and remote feature branches
git branch -d feat/BL-XXX-<owner>-<slug>
git push origin --delete feat/BL-XXX-<owner>-<slug>
```

---

## 2. The Handoff Note

After the merge is pushed and the lock is released, write a concise, plain-language
handoff note to the user:

> **Delivered BL-004 (CSV Export)**
> - Merged to `main` and verified. Users can now export their draft entries directly to CSV.
> - **In Flight:** `agent-beta` is currently building `BL-005` on `feat/BL-005-beta-autosave`.
> - **Next Up:** `BL-007` (Share link) is unblocked and ready to plan.
> - **Learnings Added:** `[Testing]` Tip for mock CSV streams added to `docs/learnings.md`.
> - **Metrics:** Completed in 28m (+62/-4 lines, 3 tests).
> Ready for next task or session clear.
