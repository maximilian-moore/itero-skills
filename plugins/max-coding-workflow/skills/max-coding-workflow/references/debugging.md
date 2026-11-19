# Debugging and root-cause reproduction

When a test fails, the build breaks, or the user reports a bug, guessing at fixes
wastes time and leaves half-reverted edits across the codebase. Find the real cause
first with one reproducible command, prove it with a failing test, then apply the
smallest possible fix.

---

## Stop the line

The moment something breaks unexpectedly:

1. **Stop adding features or making speculative edits.** Do not try three guesses in
   parallel.
2. **Preserve the failure output.** Keep the exact error message, stack trace, HTTP
   status, or failing test output before clearing anything.

## Diagnose-only or fix

If the user asked you to debug or investigate without saying whether to change code yet,
ask once unless their intent is already clear:

- **Diagnose only:** prove the root cause and write a failing regression test
  (`BUG-XXX-T01`), leaving the code unchanged so the user can review before fixing.
- **Diagnose and fix:** prove the root cause, write the failing test, apply the minimal
  fix, probe it, and verify.

Inside `/implement` or an autonomous run, always diagnose and fix once proven.

## Step 1 - Reproduce with one exact command

Before forming hypotheses or editing application code, find **one exact command** that
triggers the failure reliably on demand — a single unit or integration test, a
Playwright spec, a CLI call, or a curl request against a local test server.

Capture the command and its failing output. If you cannot make it fail reliably, you
cannot prove any fix worked.

**If it does not reproduce on the first try:**
- Check environment differences: env vars, seed data, database state, timezone, or
  browser viewport.
- If the bug involves timing or concurrency, run the single case repeatedly under the
  same conditions until the trigger is reliable.
- If a working feature broke recently and the commit is unknown, use `git bisect`
  between a known good commit and `HEAD` using your reproduction command.

## Step 2 - Test one hypothesis at a time

1. Read the full code path from entry point to failure, inspecting actual inputs, types,
   and state rather than assuming what a helper does.
2. Pick the **single most likely cause** and state what observation would confirm or
   disprove it.
3. Check it with a targeted inspection, test, or temporary log.
4. If disproven, **remove any temporary log or change immediately** before testing the
   next hypothesis. Never stack speculative edits on top of each other.

## Step 3 - Write the failing test first

Before writing the fix, encode the reproduction in an automated test carrying its ID
(`BUG-XXX-T01` or `BL-XXX-T01`). Run that test and confirm it fails for the exact right
reason — the bug itself, not a typo or missing import.

## Step 4 - Minimal fix, probe, verify, clean up

1. **Apply the smallest fix** that addresses the proven root cause. Stay inside scope
   (rule 1): if investigating revealed a separate issue or worthwhile refactor, log a
   one-line item in `backlog.md` and leave it out of this diff.
2. **Confirm green:** run the new regression test and see it pass.
3. **Probe the test** (`references/testing.md`): temporarily break one line of your fix,
   confirm the new test fails again for the right reason, then restore the fix cleanly.
4. **Run the verify command** (`scripts/verify.sh`): lint, typecheck, full tests, and
   build must all exit clean.
5. **Clean up:** remove every temporary debug log, scratch script, or local test edit.
   Read `git diff` to verify only the intended fix and regression test remain.

## Rule 4 - Three strikes, then stop

After **three failed hypotheses or three failed attempts** to reach green on the same
problem, stop coding:

1. Remove any temporary debug logs or half-finished speculative edits (`git diff` should
   not leave broken fragments behind unless captured cleanly on a WIP commit).
2. Write what you tried, the exact reproduction command, and what you observed into the
   **Gotchas** section of `project-status.md` (or under **Stuck** in `docs/blockers.md`
   during an autonomous run, then continue with independent parts).
3. Tell the user clearly what failed and ask how to proceed.
