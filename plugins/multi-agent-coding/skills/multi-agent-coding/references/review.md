# Phase 5, Step 5: Adversarial Code Review

In multi-agent systems, agents using the same underlying LLM family share common cognitive
blind spots. An implementation agent will confidently write a race condition or a missed
null check, and when asked to review its own work in the same session, it will confirm its
original reasoning.

To catch real defects, **code review must be adversarial and run in a fresh, isolated context.**

---

## 1. Two Review Passes

1. **Self-Check (Main Context):** The worker or orchestrator reads the diff against the
   requirement criteria. Catches obvious oversights (forgotten debug logs, missing files).
2. **Adversarial Subagent Review (Fresh Context):** A dedicated subagent reviews the diff
   without seeing the implementation conversation. It evaluates the code as an auditor.

---

## 2. The Adversarial Subagent Brief

Provide the subagent only the diff, the requirement, `architecture.md`, and this brief:

```
You are an adversarial code review agent auditing a pull request.
You have no prior context on this conversation. Do not assume the implementation approach
is correct. Your objective is to find bugs, security flaws, concurrency bugs, and architectural
violations before this code reaches production.

Requirement: docs/requirements/BL-XXX.md
Architecture: architecture.md
Diff: [output of `git diff origin/main...HEAD`]

Review strictly against this checklist:
1. Security & Secrets: Are any keys, tokens, or PII exposed? Is user input sanitized?
2. Concurrency & Race Conditions: Are there shared state mutations, unhandled async
   race conditions, or database transaction isolation issues?
3. Data Integrity: Can data be corrupted, partially written, or orphaned on failure?
4. Error Handling: Are edge cases, network drops, and unexpected types caught gracefully?
5. Scope Discipline: Does the diff contain changes unrelated to the requirement?

For every finding, provide:
- File and line number
- Defect description
- Potential impact
- Recommended fix
- Severity: High, Medium, or Low (using definitions below)

Do not comment on formatting or style covered by the linter.
If you find no defects at a severity level, explicitly state "None".
```

---

## 3. Severity Definitions

- **High:**
  - Security vulnerabilities (auth bypass, secret exposure, injection).
  - Data corruption or permanent data loss.
  - Fatal crash or unhandled exception in core user flows.
  - Concurrency race conditions in state/database mutations.
  *Must be resolved before merge. No exceptions.*

- **Medium:**
  - Unhandled edge cases that break non-critical functionality.
  - Logic bugs with workarounds.
  - Missing automated test coverage for critical paths.
  - Performance regressions (e.g. N+1 queries).
  *Must be resolved before merge.*

- **Low:**
  - Minor code readability improvements.
  - Non-critical dead code.
  - Non-blocking edge cases with negligible probability.
  *Fix only if quick and contained inside existing diff files; otherwise log to `backlog.md`
  under Known Issues.*

*Rule: Security, data loss, and concurrency races are never Low.*

---

## 4. Fallback for Non-Subagent Environments

If the host environment does not support spawning subagents:
1. **Persona Switch:** Open a fresh chat session or run `/clear`. Paste the brief and diff.
2. **Cross-Model Review:** If possible, use a different LLM (e.g., if Claude wrote the code,
   have Gemini review it; if Gemini wrote it, have Claude review it). Cross-model reviews
   are exceptionally effective at breaking shared model blind spots.
3. Never let the same conversational context that generated the code declare the code "approved".
