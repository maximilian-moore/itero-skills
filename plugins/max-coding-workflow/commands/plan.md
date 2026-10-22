---
description: Write the requirement, run question rounds, and write the implementation plan for one backlog item
---

Read `references/planning.md`.

If the user named a backlog item, use it. Otherwise read `backlog.md`, take the top
item from Next up that is not already `ready`, and confirm with the user before
planning.

Check the item's `Blocked by` field first. If a blocker is not `implemented`, say so
and offer the next unblocked item.

Decide the kind of item first, as `references/planning.md` describes: a `small fix` or
an `autonomous` run. Say which and why in one line; when unsure, it is autonomous.

Then move the item through its states as you work:

1. `idea` to `draft`, and write `docs/requirements/BL-XXX.md` - from
   `assets/templates/requirement-small.md` for a small fix, from
   `assets/templates/requirement.md` for an autonomous run. Commit the draft.
2. For an autonomous run, run the question rounds in `references/requirement-review.md`:
   a fresh subagent per round, triage, one batch of questions to the user, commit per
   round, at most four rounds. In Claude Code, start each round's subagent with
   `model: "sonnet"`; the reading does not need the strongest model. A small fix skips
   this step.
3. `draft` to `ready`.
4. Write the plan to `docs/plans/BL-XXX-plan.md` using
   `assets/templates/implementation-plan.md` - the how.

If the item is already `ready` its requirement file exists; reread it rather than
rewriting it, and go straight to the plan.

If the item is too big by the signals in the Sizing section of `references/planning.md`,
propose a split before writing the requirement.

Show the plan and stop. Name your assumptions explicitly and ask about those
specifically rather than asking a general "does this look right".

Do not start coding until the user approves.

Commit the requirement and the plan before any code is written. They are the durable
part; the branch is not.
