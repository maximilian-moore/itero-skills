# Phase 2: The Multi-Agent Backlog

A backlog in a multi-agent repository must balance two competing requirements:
1. It must provide absolute clarity on what is actively being built and by whom to prevent collisions.
2. It must remain lightweight and concise so agents do not burn context reading 80 completed items.

To achieve this, the backlog is split into **three focused files**:
- **`backlog.md`**: The active index. Contains only open items, in-flight claims, and the forced-rank Next Up queue.
- **`docs/delivered.md`**: The permanent delivery archive. Completed items move here at merge time.
- **`docs/cancelled.md`**: The archive of dropped items with recorded rationale.

---

## 1. Active Backlog Format (`backlog.md`)

```markdown
# Active Backlog

## In Flight

| ID | Title | Owner / Agent | Branch | Started | Blocked by |
|---|---|---|---|---|---|
| BL-004 | Export to CSV | agent-alpha | feat/BL-004-alpha-csv | 2026-10-03 | - |

## Next Up
1. BL-002
2. BL-005
3. BL-007

## Open Items by Milestone

### M1: MVP Core
| ID | Title | Value | Effort | Status | Owner | Blocked by |
|---|---|---|---|---|---|---|
| BL-002 | Save draft entry | High | Low | ready | - | BL-001 |
| BL-005 | Auto-save timer | Med | Med | draft | - | BL-002 |

### M2: Analytics & Sharing
| ID | Title | Value | Effort | Status | Owner | Blocked by |
|---|---|---|---|---|---|---|
| BL-007 | Share public link | Low | Med | idea | - | - |

## Known Issues

| ID | Title | Severity | Found in | Status |
|---|---|---|---|---|
| BUG-003 | Empty title crashes save handler | Med | BL-002 | open |
```

---

## 2. Status States and the Claim Lifecycle

An item moves through these discrete states:

| Status | Meaning | Requirement File | What Moves It |
|---|---|---|---|
| `idea` | Captured concept, unrefined | None | User or team approves exploring it |
| `draft` | Scoping in progress | Being written | Acceptance criteria & human test defined |
| `ready` | Fully specified, buildable | Complete | `/implement` picks it up |
| `implementation` | Claimed and active on branch | Complete | Checkpoint and PR merge |
| `implemented` | Shipped to `main` | Complete | **Moved to `docs/delivered.md`** |
| `cancelled` | Dropped with reason | Kept if exists | **Moved to `docs/cancelled.md`** |

### Why Items Leave `backlog.md`:
In long-running repositories, leaving dozens of `implemented` rows in `backlog.md` causes
the file to grow to thousands of lines. Every session that reads the backlog pays a context
tax for dead information. Moving completed items to `docs/delivered.md` preserves history
while keeping `backlog.md` instantly scannable.

---

## 3. The Delivered Archive (`docs/delivered.md`)

When an item is merged during `/checkpoint`, the row is deleted from `backlog.md` and
appended to `docs/delivered.md`:

```markdown
# Delivered Items Archive

| ID | Title | Milestone | Owner / Agent | Merged Date | PR / Commit | Requirement Link |
|---|---|---|---|---|---|---|
| BL-001 | User authentication | M1 | max | 2026-10-01 | #1 | [BL-001](requirements/BL-001.md) |
| BL-003 | Database session store | M1 | agent-beta | 2026-10-02 | #3 | [BL-003](requirements/BL-003.md) |
```

---

## 4. The Cancelled Archive (`docs/cancelled.md`)

When an item is permanently abandoned, it is removed from `backlog.md` and added here:

```markdown
# Cancelled Items

| ID | Title | Date Cancelled | Why It Was Dropped |
|---|---|---|---|
| BL-006 | Support legacy XML export | 2026-10-02 | All target users rely on JSON or CSV; XML adds parsing complexity. |
```
Documenting the reason prevents re-litigating rejected ideas six months later.

---

## 5. Forced Ranking: The Next Up Queue

The `Next Up` list at the top of `backlog.md` is the ground truth for priority.
Value and Effort (High/Med/Low) are discussion aids; `Next Up` is the decision.

When `/implement` runs without arguments, it picks the top item from `Next Up` that:
1. Has status `ready`.
2. Has all `Blocked by` dependencies resolved (either already in `docs/delivered.md` or marked implemented).
3. Is not currently listed in `## In Flight` or on an active remote branch.
