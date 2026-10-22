# Phase 5: The autonomous run

How an agent builds one `ready` autonomous item alone, for hours, without stopping to
ask - and how the user gets control back at the end.

A run is possible because the questions were answered before it started: the
requirement passed its question rounds (`references/requirement-review.md`) and the
user approved it. During the run, the files decide. The user decides at two points
only: before the run, by approving the requirement, and after it, in the human check.

A small fix never runs this way. It follows the normal build loop in `SKILL.md`.

---

## The run protocol file

Each project keeps its run rules in `docs/run-protocol.md`, copied from
`assets/templates/run-protocol.md` and filled in during Phase 3. It holds what every
run needs and no requirement repeats: the environments, the deploy command, the
stand-ins for external services, the stop reasons, the definition of done.

Why a project file and not only this reference: the run agent may be a different tool
from the one that planned the item, in a fresh session without the planning context.
The run prompt points at two files in the repository, and together with this skill's
review reference those are enough.

## Starting a run: the run prompt

When an autonomous item becomes `ready`, `/plan` ends by printing the run prompt.
Plain text, so any tool can run it:

```
Build BL-XXX. Follow docs/run-protocol.md and docs/requirements/BL-XXX.md.
The requirement is approved: do not wait for the user at any point.
Done when every point in section 13 of the requirement holds.
```

How to start it differs per tool, and it is the only step that does:

- **Claude Code:** pass it to `/goal`. Without `/goal`, paste it as the first message
  of a fresh session.
- **Antigravity:** give it to a new agent in the Agent Manager as its task.
- **Codex and other tools:** paste it as the task of a new session, in the tool's most
  autonomous mode the user is comfortable with.

Start the run in a fresh session. A planning session's context is full of the
discussion; the run needs the files, not the discussion.

## During the run

1. Read `docs/run-protocol.md` and the requirement in full, and the Build, Testing,
   Review and Deploy sections of `learnings.md`. Read large references - the
   prototype, the design page - only by the marker or heading the requirement names.
2. Write `docs/plans/BL-XXX-plan.md` and commit it. The approved requirement is the
   approval; continue without waiting.
3. Branch, set the item to `implementation`, commit.
4. Build test-first where the requirement names a test. Commit after each working
   step, and push regularly, so a run that dies leaves its work on GitHub.
5. Verify, open the pull request, run the review rounds (`references/review.md`).
6. Merge, deploy, take the evidence, write the check sheet (below).

## When something is missing: the blocker protocol

The decisions are in the files. When something is missing anyway, or two sources
contradict each other:

1. **Take the most conservative option**: the one that shows less data, collects less,
   keeps a gate closed, and is easiest to change later.
2. **Write it down** in `docs/blockers.md`, under "Choices taken": date, item, what was
   missing, the choice, why.
3. **Continue.**

The user confirms or overrules each choice in the human check. A confirmed choice moves
to where it belongs - section 4 of the requirement, or an ADR - and leaves
`docs/blockers.md`. The log holds only what is still open.

**The stuck rule in a run.** Three failed attempts at the same problem still mean stop
trying - but stop that part, not the run. Write what you tried and saw under "Stuck" in
`docs/blockers.md`, continue with the parts that do not depend on it, and report it at
the end. If nothing else is left, end the run.

## The only reasons to stop

The run ends early only for these, and `docs/run-protocol.md` and the requirement may
add project-specific ones:

- the next step deletes data that is not test or seed data
- a real secret or account is needed and no stand-in exists
- the only way to green weakens, skips or deletes a test
- a High review finding is still open after the rounds in `references/review.md`
- something that needs the user's hands is missing: a manual setup step, a login, a
  payment

When you stop, write the reason as the first entry under "Waiting on the user" in
`docs/blockers.md`, push everything, and end the run with a short message saying what
is done, what is not, and what the user must do.

## The end of a run: merge, deploy, human check

Merging and deploying are separate, and neither is the end.

1. **Merge.** When verify and CI are green and the review rounds are done, merge the
   pull request yourself, following the merge ritual in `references/checkpoint.md`.
   The item stays in `implementation`, with the note "merged, waiting for user check".
2. **Deploy** to the test environment named in `docs/run-protocol.md`, run the
   end-to-end tests against it, and take the screenshots from section 11.
3. **Write the check sheet**, `docs/evidence/BL-XXX.md`, from
   `assets/templates/evidence.md`: what was built and what was left out, any deviation
   from the requirement, the choices taken under the blocker protocol, the screenshots,
   and a link to the human acceptance test in section 10. It links to the requirement
   rather than copying it.
4. **Write the learnings** of the run into `learnings.md` (`references/learnings.md`):
   what cost extra tokens or time, what caused a review finding or rework, what the
   next run should do differently. Commit and push.
5. **End the run** with a message that gives the deployed address, the path of the
   check sheet, and the number of open choices to confirm.

Then the user checks. Their result goes into the check sheet:

- **Passed:** the item moves to `implemented`. Confirmed choices move out of
  `docs/blockers.md`.
- **Bugs found:** each becomes a small fix linked to the item (`Found in: BL-XXX`),
  fixed in its own pull request, deployed, and checked again. The item stays in
  `implementation` until the user's check passes.

**Only one environment?** If the project has no test environment and merging means
going live to real users, do the human check before the merge instead: run the app
locally, or on a preview of the branch if the host offers one, and merge after the user
passes it. Recommend a test environment in Phase 3; it is what makes merge-then-check
safe.

## Size

A run should fit one working session of a few hours and leave a human check of about
fifteen steps. The split signals are in the Sizing section of `references/planning.md`.
A run that is too big does not fail loudly; it runs out of budget halfway, with the
work half done and the reviews skimmed.
