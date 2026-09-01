---
description: Build the top backlog item that is ready - branch, code, verify, review, checkpoint
---

Run the Phase 5 build loop for one backlog item that is in status `ready`.

One PR is one backlog item. This command builds exactly one item and stops. If more
items are ready afterwards, the user runs `/implement` again in a fresh session.

## 1. Find the ready items

Read `backlog.md`. List every item with status `ready`, ordered by their position in
`Next up`, with anything not in `Next up` after them:

```
Ready to build:
  1. BL-004  Export to CSV          value High / effort Low   (Next up #1)
  2. BL-002  Save a draft entry     value High / effort Med
```

Then handle the edge cases before going further:

- **Nothing is `ready`.** Do not build a `draft` or `idea` item. Say what is in `draft`
  and offer `/plan` to turn one into a requirement, which is what moves it to `ready`.
- **An item is already in `implementation`.** Something was left unfinished. Report it,
  check whether its branch still exists, and ask whether to resume it or set it back to
  `ready` before starting anything new.
- **The top item has an unresolved `Blocked by`.** Skip it, say why, and offer the next
  unblocked one.

## 2. Confirm the pick

Name the item you intend to build and wait for the user to confirm or choose another.
One line, not a menu of process options.

## 3. Check that a plan exists

Look for `docs/plans/BL-XXX-plan.md`.

- **No plan:** run `/plan` for this item now, show it, and wait for approval. Do not
  code against an unapproved plan.
- **Plan exists:** show its Steps and Risks sections and confirm they still hold. Plans
  go stale when the repo moves under them.

## 4. Branch and mark it

```bash
git checkout main && git pull --ff-only
git checkout -b feat/BL-XXX-short-slug
```

Set the item's status in `backlog.md` to `implementation` and commit that on the branch.
The status is what tells a future session that this work exists.

## 5. Build

Follow the plan. Write the code and its automated tests together, not tests afterwards.

Stay inside the plan's scope. Anything worth doing that is outside it becomes a new
`idea` row in `backlog.md`, one line, and you move on. That is rule 1 and it is the
whole reason reviews stay reviewable.

Three failed attempts at the same problem means stop. Write what you tried and what you
saw into the Gotchas section of `project-status.md` and ask the user how to proceed.

## 6. Verify

Run the verify command. It must exit clean. Never ask for review on a red build.

## 7. Self-check, then review

Reread your own diff against the requirement file first - it is cheap and it catches
real mistakes. Then run `/review`, which spawns the independent subagent pass and
triages the findings. Fix High and Medium. Everything unfixed becomes a `BUG-XXX` row
in Known issues.

Re-run verify after the fixes.

## 8. Human acceptance test

Confirm the requirement file's Human acceptance test still matches what was built, and
walk the user through it. Plain language, numbered steps, no jargon. Automated tests
prove nothing broke; this proves something works.

## 9. Checkpoint

Run `/checkpoint`: update `project-status.md`, move the item to `implemented` in
`backlog.md`, add any ADR, merge, then write the handoff note and recommend a fresh
session.

Report at the end: what was built, what the review found, what was deferred to the
backlog, and which items are still `ready`.
