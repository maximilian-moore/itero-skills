---
description: Run two independent subagent review rounds on the current branch, fixing after each
---

Read `references/review.md`.

1. Run the verify command first. If it fails, stop and fix that before reviewing.
2. Do the self-check pass on your own diff.
3. Round 1: spawn a subagent with the scoped brief from the reference file. Give it
   only the diff, the requirement file, `architecture.md`, and the checklist. Nothing
   from this conversation.
4. Triage the findings here in the main context using the severity definitions.
5. Fix High and Medium. Fix Low only if small and inside files already in the diff.
6. Re-run verify after fixes, then commit and push to the pull request branch.
7. Round 2: spawn a new subagent with the same brief and the updated diff. Give it
   nothing from round 1. Repeat steps 4 to 6.
8. If a High is still open, fix it and run another round. After three rounds with an
   open High, stop and ask the user.
9. Log everything unfixed to Known issues in `backlog.md`.
10. Report per round what was found, fixed, and deferred.
