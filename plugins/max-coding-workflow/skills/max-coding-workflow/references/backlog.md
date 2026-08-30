# Phase 2: The backlog

Two files, two jobs. This split is deliberate and it is what keeps the backlog usable
after fifty items.

- **`backlog.md`** is an index. One line per item. Scannable in ten seconds.
- **`docs/requirements/BL-XXX.md`** is the detail. Full requirement, acceptance
  criteria, test cases. Created only when an item moves from `idea` to `ready`.

If you put the full requirement text in the index, the index becomes a 2,000-line
document nobody reads, and the whole thing quietly stops working.

---

## The index format

```markdown
# Backlog

## Next up
1. BL-004
2. BL-002
3. BL-007

## Items

| ID | Title | Value | Effort | Status | Blocked by |
|---|---|---|---|---|---|
| BL-001 | User can log in with email | High | Med | done | - |
| BL-002 | Save a draft entry | High | Low | ready | BL-001 |
| BL-004 | Export to CSV | Med | Low | idea | - |

## Known issues

| ID | Title | Severity | Found in | Status |
|---|---|---|---|---|
| BUG-003 | Empty title crashes the save handler | Med | BL-002 | open |
```

**Status values:**
- `idea` - captured, not thought through, no requirement file yet
- `ready` - requirement file written, acceptance tests defined, could be built today
- `in-progress` - a branch exists
- `done` - merged to main
- `discarded` - decided against, kept with a one-line reason

Keep discarded items. The reason you rejected something is genuinely useful six months
later when you consider it again.

## Value and effort

High, Medium, Low on both. Two rules stop these from becoming meaningless:

**Everything cannot be High value.** If more than about a third of open items are High,
the scale has collapsed. Re-rate them. High means the product is noticeably worse
without it, not that it would be nice.

**The Next up list is the real priority.** Value and effort are inputs to a
conversation. The ranked list at the top is the decision. When the user asks "what
next", read the list, do not re-derive it from the buckets. Forced ranking prevents the
comfortable fiction that six things are all the top priority.

## Dependencies

The `Blocked by` column holds item IDs, not prose. Before starting any item, check it.
If a blocker is not `done`, say so and offer the next unblocked item.

Watch for circular dependencies when filling the initial backlog. If A blocks B and B
blocks A, one of them is really two items and needs splitting.

## The requirement file

Created when an item moves to `ready`, not before. Use
`assets/templates/requirement.md`. It contains:

- **What and why** - one paragraph, in user language
- **Acceptance criteria** - a checklist of observable behaviours
- **Human acceptance test** - numbered plain-language steps, no jargon, so the user
  can verify it works without reading code
- **Automated test notes** - what the AI should cover with real tests
- **Architecture impact** - does this change anything in `architecture.md`?
- **Out of scope** - what this item deliberately does not do

The human acceptance test is the piece most people skip, and it is the one that catches
"all tests pass but the feature is useless". Write it before the code, not after,
because writing it afterwards means writing it to match whatever got built.

## Adding items mid-flight

During Phase 5, when something out of scope surfaces, add it here with status `idea`
and move on. That is the entire mechanism behind rule 1. It only works if adding an
item is fast, so keep it to one line and do not stop to write a requirement file.
