---
description: Reproduce a bug with one exact command, isolate root cause, prove it with a failing test, then apply a minimal fix
---

Read `references/debugging.md`.

Work through a bug systematically instead of guessing at fixes:

1. **Confirm mode if unclear.** Unless the user already said to fix it (or you are
   inside `/implement` or an autonomous run), ask once whether they want **diagnose
   only** (prove root cause + failing test) or **diagnose and fix**.
2. **Stop the line and reproduce.** Find one exact command that fails reliably on
   demand and capture its output before editing any application code. If it does not
   reproduce immediately, isolate environment/seed/timing differences or use
   `git bisect`.
3. **Test one hypothesis at a time.** Read the actual code path and trace inputs/state.
   Check one explanation at a time and revert any temporary probe before trying the
   next. Never stack speculative changes.
4. **Follow the stuck rule (rule 4).** After three failed hypotheses or attempts at the
   same problem, stop coding, clean up temporary logs, record what you tried and saw in
   `project-status.md` under Gotchas (or `docs/blockers.md` in an autonomous run), and
   ask the user how to proceed.
5. **Prove-It test first.** Write a failing automated test (`BUG-XXX-T01` or
   `BL-XXX-T01`) that triggers the exact bug, and confirm it runs red for the right
   reason.
6. **Minimal fix, probe, verify.** Apply the smallest fix for the proven cause (stay
   inside scope; log unrelated issues to `backlog.md`). Confirm the test passes, probe
   the new test (`references/testing.md`) to prove it fails when the fix is broken,
   restore cleanly, run `scripts/verify.sh`, and remove all temporary debug output.
7. **Report clearly.** State the reproduction command, the proven root cause, the test
   added, the minimal fix (if applied), and the verify output.
