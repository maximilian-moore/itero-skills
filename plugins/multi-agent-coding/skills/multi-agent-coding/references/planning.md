# Phase 5, Step 2: The Multi-Agent Implementation Plan

One plan per backlog item. Never a global plan for the whole project.

In a collaborative or multi-agent repository, planning carries an additional duty:
**anticipating concurrency friction before code is written.**

A plan must explicitly evaluate whether the proposed changes touch shared files,
introduce database migrations, or modify package dependencies. Catching these early
prevents merge nightmares later.

---

## 1. Lifecycle of the Plan

- An item moves from `idea` to `draft` when you start specifying it.
- Write the requirement file at `docs/requirements/BL-XXX.md` using `assets/templates/requirement.md`.
  It defines the *what* in user language, with acceptance criteria and a plain-language
  human acceptance test.
- Once criteria are complete, move the item to `ready`.
- Then author the implementation plan at `docs/plans/BL-XXX-plan.md` using
  `assets/templates/implementation-plan.md`. It defines the *how*.

The requirement persists in the repository and serves as the benchmark for code review.
The plan is disposable and deleted or archived when the PR merges.

---

## 2. The Plan Template

```markdown
# BL-XXX: [Title]

## Goal
One sentence. What will be true when this is merged that is not true now.

## Approach
Two or three sentences on how. High-level architecture and data flow.

## Concurrency & Conflict Assessment
- **Schema / Migration Impact:** [None / Adds table 'sessions' with sequence 0004]
- **Dependency / Lockfile Impact:** [None / Adds 'csv-parse@^5.5']
- **Shared File Hotspots:** [None / Touches `src/middleware.ts` which BL-005 also touches]

## Target Files
- `src/services/csv-exporter.ts` - new - handles CSV serialization
- `src/app/api/export/route.ts` - new - API route
- `src/components/export-button.tsx` - modified - UI trigger

## Steps
1. ...
2. ...

## Automated Tests
- What unit/integration tests get added, and what failure mode each test catches.

## Human Acceptance Test
1. Plain-language step 1
2. Plain-language step 2
3. Observable outcome

## Architecture Impact
None / Updates ADR-002 because...

## Risks & Out of Scope
- What is explicitly left out of this item.
```

---

## 3. Concurrency Assessment Rules

Every plan must explicitly answer the three concurrency questions:

1. **Schema Impact:** If `Yes`, the implementer knows to check for migration collisions
   during rebase.
2. **Dependency Impact:** If `Yes`, the implementer knows to use the package manager's
   clean install during rebase rather than attempting manual lockfile merge.
3. **Shared File Hotspots:** If the plan touches a file already touched by an in-flight
   branch listed in `project-status.md`, flag it immediately. The user can decide
   whether to serialize the items or structure the edits to minimize conflicts.

---

## 4. The Approval Gate

Present the plan to the user with named assumptions:
> *"Here is the plan for BL-004. I am assuming we stream the CSV download rather than
> generating a temp file on disk, and that auth token verification is handled by middleware.
> Both look good to proceed?"*

Do not write code until the user approves. Once approved, commit the requirement and plan,
assert the remote branch lock, and dispatch the Worker Subagent.
