# Phase 5, step 2: The implementation plan

One plan per backlog item. Never a global plan for the whole project.

The reason: priorities shift. Items get deprioritised, split, or cancelled. A global
plan has to be maintained for work that may never happen, so it rots, and a rotten plan
is worse than none because people still half-trust it. A per-item plan is written when
the item is picked and thrown away when it merges. It cannot rot, because it does not
outlive the work.

The durable cross-cutting decisions live in `architecture.md`. That is the difference:
architecture persists, plans are disposable.

---

## Two kinds of item

Decide this first, because it sets how much planning the item gets.

**Small fix.** One visible change or one bug: a text, an alignment, a colour, a single
wrong behaviour. About three files or fewer, no new data, no new rules or permissions.
It gets the short requirement (`assets/templates/requirement-small.md`) and no question
rounds. Writing it takes minutes, and the cost of a misunderstanding is small.

**Autonomous run.** Everything else: a feature, a screen, a flow, a milestone. It gets
the full requirement (`assets/templates/requirement.md`), written so an agent can build
it alone for hours without asking, and question rounds check that before it is `ready`.

When unsure, it is an autonomous run. A "small fix" that touches a database table, a
permission or a second screen is not small. If a small fix grows while you write it,
switch templates rather than stretching the short one.

Record the kind in the file's `Run:` line.

## What planning does to the item's status

Planning is what moves a backlog item along, so update `backlog.md` as you go rather
than at the end.

- Item is `idea`: move it to `draft` before writing anything, then write the
  requirement file at `docs/requirements/BL-XXX.md`. The requirement is the *what*, in
  the user's language. Do not start the plan until it exists.
- For an autonomous run, check that its blockers are `implemented` before you write the
  requirement. A requirement is checked against the code it builds on, so write it
  right before the build, not weeks ahead.
- Run the question rounds on an autonomous requirement (`references/requirement-review.md`).
  A small fix skips them.
- Then move the item to `ready`. That is the state `/implement` looks for. A small fix
  is `ready` when a person could tell from the file alone whether the built thing is
  correct. An autonomous run is `ready` when, in addition, an agent could build it from
  the file alone without asking: the question rounds have ended with no critical
  finding.
- Then write the implementation plan, which is the *how*.

Requirement and plan are two files on purpose. The requirement outlives the work and
is what the reviewer checks the diff against. The plan is thrown away when the item
merges. Collapsing them means either losing the requirement or keeping stale plans.

`/implement` sets the item to `implementation`; `/checkpoint` sets it to `implemented`.
Neither is your job here.

---

## The plan template

Save to `docs/plans/BL-XXX-plan.md`. Use `assets/templates/implementation-plan.md`.

```markdown
# BL-XXX: [Title]

## Goal
One sentence. What will be true when this is merged that is not true now.

## Approach
Two or three sentences on how. Enough that the user can spot a wrong approach
without reading code.

## Files
- `path/to/file.ts` - new - what it does
- `path/to/other.ts` - modified - what changes

## Steps
1. ...
2. ...

## Automated tests
- What gets covered, and specifically what failure each test would catch.

## Human acceptance test
1. Run `npm run dev` and open http://localhost:3000
2. Click "New entry"
3. Type anything and press Save
4. You should see it appear at the top of the list with today's date
5. Refresh the page. It should still be there.

## Architecture impact
None. / Changes ADR-002, new ADR to be added in this PR because ...

## Risks
What could go wrong, what you are unsure about.

## Out of scope
What this explicitly does not do. Reference backlog IDs where they exist.
```

---

## Sizing

An item has to fit three limits: one review, one human check, and one working session.
A run that is too big gets skimmed in review, leaves the user a check list nobody
finishes, and runs out of budget halfway with the work half done.

Suggest a split when any of these is true. They are signals, not hard limits; the user
decides.

- A small fix needs more than about three files. It is not a small fix.
- The requirement file is above about 100 KB.
- Section 9 has more than about 25 named tests.
- The human acceptance test has more than about 15 steps.
- The item touches more than two areas of the product, such as sign-in and payments
  and the dashboard.
- The build would not fit in one working session of a few hours.

To split, cut along what the user can check on their own: each piece should be
testable by a person without the next one. Update `backlog.md` with the new IDs and
their `Blocked by`, and plan only the first piece.

Large pull requests are not reviewable, by a human or a subagent. A diff nobody can
hold in their head gets skimmed and approved, which produces the illusion of review
with none of the benefit.

## The two test sections

They are different things and both are required.

**Automated tests** are the regression net. They prove that what worked yesterday still
works today. Write them with the code, not afterwards, because tests written afterwards
are written to match whatever got built, including its bugs. Each named test in the
requirement (`BL-XXX-T01` ...) puts its ID in the test's title, so a search shows that
every criterion has a test.

**The human acceptance test** is the proof that the feature is actually useful. Plain
language, numbered steps, no jargon, no assumed knowledge. The user should be able to
follow it on a phone while holding a coffee.

Write it so it fails informatively. "You should see the note at the top of the list
with today's date" is testable. "It should work correctly" is not.

## Architecture impact

Answer this honestly for every plan. If the item changes a recorded decision,
`architecture.md` gets a new ADR in this same PR. See `references/architecture.md`.

The temptation is to write "None" without checking. Actually check. Ask: does this
introduce a new dependency, a new data store, a new external service, a new auth path,
or a new deployment requirement? Any yes means the answer is not None.

## The approval gate

Show the plan and stop. Do not begin coding.

Ask specifically, not generally. "Does this look right?" gets a reflexive yes. Better:
"Two things I would check: I am assuming entries are never edited after saving, and I
am storing timestamps in UTC. Both fine?"

Named assumptions get corrected. Open questions get waved through.

Once approved, create the branch and build. If the plan turns out to be wrong halfway
through, stop and revise the plan with the user rather than improvising past it. An
improvised deviation is invisible to the reviewer later, because the reviewer compares
the diff to the requirement, not to your intentions.
