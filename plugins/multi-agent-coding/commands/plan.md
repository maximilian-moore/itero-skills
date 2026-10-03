---
description: Write a requirement and implementation plan for one backlog item with concurrency checks
---

Read `references/planning.md`.

If the user named a backlog item, use it. Otherwise inspect `backlog.md`, take the top
unblocked item from `Next up` that is not already `ready`, and confirm with the user.

Check `Blocked by` first. If a blocker is not delivered, say so and offer the next unblocked item.

Work through the planning sequence:

1. **Move `idea` to `draft`:**
   Write `docs/requirements/BL-XXX.md` from `assets/templates/requirement.md`.
   Define the *what*, in user language, with acceptance criteria and a plain-language
   human acceptance test.
2. **Move `draft` to `ready`:**
   Once acceptance criteria and the human acceptance test are fully specified.
3. **Write the Implementation Plan:**
   Create `docs/plans/BL-XXX-plan.md` using `assets/templates/implementation-plan.md`.
   Assess and document:
   - Concurrency Assessment: Schema / Migration impact, Dependency / Lockfile impact, and Shared Hotspots.
   - Target files and implementation steps.
   - Automated test notes and plain-language human acceptance test.
   - Architecture impact (if any ADR is required).
4. **Show the plan and stop:**
   Name your assumptions explicitly and wait for user approval.
   Do not start coding until the user approves.
5. **Commit the requirement and plan:**
   Commit the documentation before claiming the branch.
