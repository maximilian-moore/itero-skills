---
description: Update project status, merge the PR, write a handoff note
---

Read `references/checkpoint.md`.

Work through the merge ritual in order. Do not merge until `project-status.md` is
updated, the item is moved from `implementation` to `implemented` in `backlog.md` along
with any new `BUG-XXX` rows, and `architecture.md` carries any new ADR.

Then write a plain-language handoff note and recommend a fresh session.

If nothing is ready to merge, do the status update alone. A mid-session checkpoint is
still worth doing, especially if the user is stopping for the day or a phase just
completed.

If work is being abandoned rather than finished, do not leave the item in
`implementation` - that state means a live branch. Move it back to `ready` if it is
paused, or to `cancelled` with a one-line reason if it is dropped for good, so the next
`/start` reports the truth.
