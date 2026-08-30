---
description: Run the subagent code review on the current branch
---

Read `references/review.md`.

1. Run the verify command first. If it fails, stop and fix that before reviewing.
2. Do the self-check pass on your own diff.
3. Spawn a subagent with the scoped brief from the reference file. Give it only the
   diff, the requirement file, `architecture.md`, and the checklist. Nothing from this
   conversation.
4. Triage the findings here in the main context using the severity definitions.
5. Fix High and Medium. Fix Low only if small and inside files already in the diff.
6. Log everything unfixed to Known issues in `backlog.md`.
7. Re-run verify after fixes.
8. Report what was found, fixed, and deferred.
