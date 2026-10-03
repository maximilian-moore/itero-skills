---
description: Run an adversarial subagent code review on the active feature branch
---

Read `references/review.md`.

Execute the independent code review pass:

1. **Verify gate:** Run `./scripts/verify.sh`. Must pass before review begins.
2. **Self-check:** Review diff against requirement criteria.
3. **Dispatch Reviewer Subagent:**
   Spawn a reviewer subagent with the scoped brief from `references/review.md`.
   Provide ONLY:
   - Git diff: `git diff origin/main...HEAD`
   - Requirement file: `docs/requirements/BL-XXX.md`
   - Architecture file: `architecture.md`
   - Adversarial checklist (Security, Concurrency, Data Integrity, Error Handling)
   Provide *nothing* from the implementation conversation.
4. **Triage findings:**
   - Resolve all **High** and **Medium** findings immediately.
   - Low findings: fix if small and inside the diff; otherwise log to Known Issues in `backlog.md`.
5. **Re-run verify:** Confirm `./scripts/verify.sh` passes after all fixes.
6. **Report results:** Present summary of findings, fixes, and deferred items to the user.
