---
description: Run the independent review rounds for the item's kind on the current branch, fixing after each
---

Read `references/review.md`.

1. Run the verify command first. If it fails, stop and fix that before reviewing.
2. Do the self-check pass on your own diff.
3. Read the item's `Run:` line in its requirement file.
4. Round 1: spawn a subagent with the correctness brief from the reference file. Give
   it only the diff, the requirement file, `architecture.md`, and the checklist.
   Nothing from this conversation. For an autonomous run, or a small fix that touches
   secrets, authentication, user data, payments or deletion, spawn a second subagent
   with the security brief in parallel. In Claude Code, the correctness reviewer may
   run with `model: "sonnet"`; the security reviewer uses the strongest model.
5. Triage the findings here in the main context using the severity definitions.
6. Fix High and Medium, each High with a test. Fix Low only if small and inside files
   already in the diff.
7. Re-run verify after fixes, then commit and push to the pull request branch.
8. A small fix stops here. For an autonomous run, round 2: a new subagent with the
   correctness brief, the updated diff and the changes since round 1, and nothing from
   round 1's findings. Fix Medium and easy Lows. A High: fix, test, one short review of
   that fix; still open, stop and ask the user.
9. Log everything unfixed to Known issues in `backlog.md`.
10. Report per round what was found, fixed, and deferred.
