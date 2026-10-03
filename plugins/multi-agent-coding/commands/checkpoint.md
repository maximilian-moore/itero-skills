---
description: Upstream rebase, verify, archive delivered item, harvest learnings, log metrics, and merge PR
---

Read `references/checkpoint.md`, `references/learnings.md`, and `references/metrics.md`.

Execute the full delivery checkpoint in order:

1. **Upstream rebase:**
   ```bash
   git fetch origin main
   git rebase origin/main
   ```
2. **Lockfile & migration check:**
   - If dependencies changed, run package manager clean install (`npm install`, `pnpm install`, etc.).
   - Check database migrations for sequence conflicts.
3. **Verify gate:** Run `./scripts/verify.sh`. Must exit clean.
4. **Review check:** Confirm subagent review is complete and findings triaged.
5. **Human acceptance test:** Execute plain-language test steps from the requirement file.
6. **Archive delivered item:**
   - Remove item from `backlog.md`.
   - Append row to `docs/delivered.md` with ID, Title, Milestone, Owner, Date, and Requirement link.
7. **Update project status:**
   - In `project-status.md`: remove from `## In Flight`, add to `Recently Merged`, update `What Works Today` and `Last updated`.
8. **Harvest continuous learnings:**
   - Evaluate against the 4 learning questions in `references/learnings.md`.
   - Append any discoveries, traps, or speedups to `docs/learnings.md` with domain tags.
9. **Log metrics:**
   - Extract git diff stats (`git diff --stat origin/main...HEAD`), duration, contributor, and model.
   - Append row to `docs/project-metrics.md`.
10. **Merge & release distributed lock:**
   ```bash
   git add .
   git commit -m "docs(checkpoint): deliver BL-XXX, update status, learnings and metrics"
   git checkout main
   git pull --ff-only origin main
   git merge --ff-only feat/BL-XXX-<owner>-<slug>
   git push origin main
   git branch -d feat/BL-XXX-<owner>-<slug>
   git push origin --delete feat/BL-XXX-<owner>-<slug>
   ```
11. **Write handoff note:** Summarize delivered capabilities, in-flight state, and next unblocked item.
