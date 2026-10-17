---
description: End the session cleanly - update the status, sync with GitHub, write docs/handover.md, print a restart prompt
---

Read `references/handover.md` and follow it in order.

1. **Make the repository true.** Update `project-status.md` (Last updated, Where we are,
   Next step, Open decisions, Gotchas) and `backlog.md`. Write every decision from this
   session into the file where it belongs.
2. **Commit and push.** Half-finished work goes onto its branch as a work-in-progress
   commit and is pushed. Never put unreviewed work onto main to hand it over.
   `git status -sb` must show a clean tree, not ahead of upstream.
3. **Write `docs/handover.md`** from `assets/templates/handover.md`: Written at (date and
   commit hash), Where we stopped, Next action, Read first (and what not to read in
   full), Decided this session, Waiting on the user, Watch out, Working agreements, and
   the restart prompt. Link to facts; do not copy them.
4. **Run the self-check** in the reference file. Fix any gap.
5. **Commit and push `docs/handover.md`.**
6. **Print the restart prompt** in a code block, and tell the user it is safe to start a
   fresh session or run `/clear`.

Keep the restart prompt to ten lines or fewer. It points at files; it does not contain
them.
