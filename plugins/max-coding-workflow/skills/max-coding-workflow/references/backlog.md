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
| BL-001 | User can log in with email | High | Med | implemented | - |
| BL-002 | Save a draft entry | High | Low | ready | BL-001 |
| BL-004 | Export to CSV | Med | Low | draft | - |
| BL-007 | Share a link to an entry | Low | Med | idea | - |

## Known issues

| ID | Title | Severity | Found in | Status |
|---|---|---|---|---|
| BUG-003 | Empty title crashes the save handler | Med | BL-002 | open |
```

## Status: the six states

An item moves through these in order. The value of a small fixed vocabulary is that
`/start` and `/implement` can act on it without asking you what anything means.

| Status | Meaning | Requirement file | What moves it on |
|---|---|---|---|
| `idea` | Captured, not thought through | none | You decide it is worth building |
| `draft` | Worth building, being specified | being written | Acceptance tests are written |
| `ready` | Buildable today | complete | `/implement` picks it up |
| `implementation` | A branch exists, work in flight | complete | The PR merges |
| `implemented` | Merged to main | complete | nothing, it is finished |
| `cancelled` | Dropped for good, not coming back | whatever exists | nothing, it is closed |

The two states people skip are the two that matter.

**`draft` is the thinking state.** It exists so that "I want this" and "I know what
this is" are not the same row. An item sitting in `draft` is an open question about
scope, and seeing three of them tells you the backlog is ahead of your thinking. Start
the requirement file here; the item is not `ready` until its acceptance tests are
written, because acceptance tests are where vague ideas fall apart.

**`implementation` is the crash marker.** Set it when the branch is created, not when
the work is done. If a session dies mid-feature, the next `/start` sees an item in
`implementation` with no merged PR and knows to ask about it. Without that state, the
half-finished branch is simply lost.

`cancelled` replaces deleting the row. The item is dropped: it does not come back, it
does not get re-ranked, and nothing in the process will surface it again. Keep the row
and a one-line reason anyway, because why you decided against something is genuinely
useful six months later, and it stops the same idea being re-litigated every quarter.

Cancelled is a decision, not a parking space. If you might still want something, it
stays an `idea` - that is what `idea` is for. Reaching for `cancelled` because an item
is merely not urgent is how a backlog quietly loses work you meant to keep.

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
If a blocker is not `implemented`, say so and offer the next unblocked item.

Watch for circular dependencies when filling the initial backlog. If A blocks B and B
blocks A, one of them is really two items and needs splitting.

## The requirement file

Started when an item moves to `draft`, finished when it moves to `ready`. Not before:
an `idea` with a requirement file is an idea you have over-invested in. Use
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

`/plan` is what promotes an item from `idea` to `draft` to `ready`. `/implement` only
ever picks up `ready` items, so an item that never gets planned never gets built. That
is deliberate: it makes the cost of an unspecified idea visible instead of letting it
be discovered halfway through the code.
