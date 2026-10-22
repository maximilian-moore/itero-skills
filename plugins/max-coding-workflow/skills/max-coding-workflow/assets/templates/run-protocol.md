# Run protocol

Read this in full at the start of every autonomous run, together with the requirement
file the run prompt names. Between them they hold everything the run needs. Do not
wait for the user at any point; the user decides before the run (the approved
requirement) and after it (the human check).

## Working steps
1. Read this file and the requirement in full. Read large references only by the
   marker or heading the requirement names: [e.g. search prototype/index.html for
   "SCREEN: <name>"; never read it whole].
2. Write `docs/plans/BL-XXX-plan.md` and commit it. The requirement is approved, so
   continue straight away.
3. Branch `feat/BL-XXX-short-slug`. Set the item to `implementation` in `backlog.md`.
   Commit after each working step and push regularly.
4. Build test-first where the requirement names a test. Each test carries its ID
   (`BL-XXX-T01`) in its title.
5. Run `scripts/verify.sh`. All green. Never weaken, skip or delete a test to get there.
6. Open a pull request. Run the review rounds for an autonomous run in
   `references/review.md` of the max-coding-workflow skill: round 1 correctness and
   security in parallel, fix, round 2 correctness, fix.
7. Merge when verify and CI are green. Update `project-status.md` and `backlog.md`
   (the item stays `implementation`, note "merged, waiting for user check").
8. Deploy to the test environment, run the end-to-end tests against it, take the
   screenshots from the requirement's section 11.
9. Write `docs/evidence/BL-XXX.md` and end the run with the address, the path of that
   file, and the number of open choices.

## Environments
| Name | Address | How to deploy | Data |
|---|---|---|---|
| local | [http://localhost:3000] | [npm run dev] | seed data |
| test | [address, or "none - check before merge"] | [command] | seed data |
| production | [address] | [command - never deployed by a run] | real data |

## Stand-ins for external services
| Service | Stand-in in tests and local runs | Real one needs |
|---|---|---|
| [Email] | [writes to a local mailbox / log] | [key in .env, see docs/SETUP.md] |

## Non-negotiable rules
- [Project rules every run must keep: who may see which data, where secrets live,
  what never goes into client code]

## Blocker protocol
When something is missing or two sources contradict each other: take the most
conservative option (shows less data, collects less, keeps a gate closed, easiest to
change later), write it under "Choices taken" in `docs/blockers.md`, and continue.

Three failed attempts at the same problem: write it under "Stuck" in
`docs/blockers.md`, continue with the parts that do not depend on it.

## Stop only when
- the next step deletes data that is not test or seed data
- a real secret or account is needed and no stand-in exists
- the only way to green weakens, skips or deletes a test
- a High review finding is still open after the review rounds
- a manual step by the user is missing
- [project-specific reasons]

When you stop: the reason goes first under "Waiting on the user" in
`docs/blockers.md`, push everything, end with what is done, what is not, and what the
user must do.

## Definition of done (every run)
- Every named test of the requirement exists and passes, locally and in CI.
- Earlier tests still pass.
- The pull request had its review rounds and is merged; CI on main is green.
- The test environment runs main, and the end-to-end tests passed there.
- The screenshots exist and `docs/evidence/BL-XXX.md` is written.
- The documentation in section 12 of the requirement is updated.
