---
description: Write an implementation plan for one backlog item
---

Read `references/planning.md`.

If the user named a backlog item, use it. Otherwise read `backlog.md`, take the top
item from Next up that is not already `ready`, and confirm with the user before
planning.

Check the item's `Blocked by` field first. If a blocker is not `implemented`, say so
and offer the next unblocked item.

Then move the item through its states as you work:

1. `idea` to `draft`, and write `docs/requirements/BL-XXX.md` from
   `assets/templates/requirement.md` - the what, in user language, with acceptance
   criteria and a plain-language human acceptance test.
2. `draft` to `ready` once those acceptance tests are written.
3. Write the plan to `docs/plans/BL-XXX-plan.md` using
   `assets/templates/implementation-plan.md` - the how.

If the item is already `ready` its requirement file exists; reread it rather than
rewriting it, and go straight to the plan.

Show the plan and stop. Name your assumptions explicitly and ask about those
specifically rather than asking a general "does this look right".

Do not start coding until the user approves.

Commit the requirement and the plan before any code is written. They are the durable
part; the branch is not.
