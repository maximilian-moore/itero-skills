# Orchestrator & Worker Subagent Architecture

In multi-agent and multi-session development, context bloat is the primary cause of
agent degradation. When a single conversation handles user dialogue, feature planning,
file reads, compiler iterations, test runs, diff inspection, and review, the context
window quickly approaches 100k+ tokens. Early decisions are forgotten, hallucinations
increase, and costs skyrocket.

The solution: **Orchestrate High, Delegate Low.**

---

## 1. Roles and Responsibilities

### The Orchestrator (Main Session Agent)
- **Scope:** High-level project coordination, user interaction, requirements triage.
- **Owns:**
  - Reading `project-status.md`, `backlog.md`, and `docs/learnings.md`
  - Facilitating kickoff and feature planning discussions with the user
  - Locking and claiming tasks
  - Dispatching Worker Subagents and Reviewer Subagents
  - Evaluating subagent results and presenting clean summaries to the user
  - Conducting checkpoints, status updates, and archiving
- **What it does NOT do:** It does not read dozens of source files or run long iterative
  coding/debugging loops directly in the main context when subagents are available.

### The Worker Subagent (Implementation Specialist)
- **Scope:** Tactical execution of a single approved implementation plan.
- **Spawned with:**
  - The feature requirement (`docs/requirements/BL-XXX.md`)
  - The approved implementation plan (`docs/plans/BL-XXX-plan.md`)
  - Relevant repo learnings from `docs/learnings.md`
  - Explicit boundaries: target files and branch name
- **Does:**
  - Implements the code changes
  - Writes automated tests alongside the code
  - Runs `verify.sh` until all tests, lint, and build pass
  - Performs self-check on the diff
- **Returns:** A concise completion report to the Orchestrator with:
  - Files modified/added
  - Verification test results
  - Any unexpected discoveries or blockers encountered
- **Disposability:** The worker's entire internal reasoning, compiler tracebacks, and
  debug logs are discarded when the subagent finishes. The main context remains lean.

### The Reviewer Subagent (Independent Auditor)
- **Scope:** Adversarial code audit.
- **Spawned with:** The clean diff (`git diff origin/main...HEAD`), requirement, and checklist.
- **Never sees:** The implementation dialogue or reasoning. Returns triaged defect list.

---

## 2. Dispatching the Worker Subagent

When `/implement` is triggered and the plan is approved, the Orchestrator composes a
targeted worker brief:

```markdown
You are a worker subagent assigned to implement backlog item BL-XXX.
Do not ask high-level product questions; execute the approved plan strictly.

Feature Requirement: docs/requirements/BL-XXX.md
Implementation Plan: docs/plans/BL-XXX-plan.md
Target Branch: feat/BL-XXX-<owner>-<slug>

Instructions:
1. Review the plan's Steps, Target Files, and Automated Tests.
2. Review relevant repo learnings in docs/learnings.md.
3. Write the necessary code and unit/integration tests.
4. Run the project verification gate: `./scripts/verify.sh`.
5. Fix any compiler, lint, or test failures.
6. When verify.sh passes cleanly, commit the changes to your branch.
7. Return a structured report:
   - Summary of changes made
   - Verification status (tests passing)
   - Discovered quirks or suggestions for docs/learnings.md
```

---

## 3. Graceful Degradation (Tools without Subagent Support)

If your environment does not support native subagent spawning (such as basic CLI tools or
simple chat interfaces), apply this fallback sequence:

1. **Context Boundary via Session Clearing (`/clear`):**
   - Finish the planning phase and commit the plan to git.
   - Run `/clear` or start a new session.
   - In the new session, run: *"I am implementing BL-XXX on branch `feat/BL-XXX-...`. Read `docs/plans/BL-XXX-plan.md` and build it."*
   - Once verified, commit, clear, and return to the orchestrator role.

2. **Split Sessions (Two Terminal Windows):**
   - Keep one terminal window as the Orchestrator / Project Manager.
   - Open a secondary terminal for the Worker. Direct the worker to execute the plan on
     the feature branch.
   - When the worker pushes commits, the Orchestrator inspects the branch, reviews,
     and merges.

Never allow an agent to skip the separation between planning, building, and reviewing
just because subagents are not natively built into the host harness.
