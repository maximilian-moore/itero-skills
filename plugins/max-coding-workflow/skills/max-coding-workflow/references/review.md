# Phase 5, step 8: Code review

Two passes, and they catch different things.

**The self-check** happens in the main context. Reread your own diff against the
requirement. This is cheap and it does find real mistakes: forgotten error handling,
a missed acceptance criterion, debug output left behind.

**The subagent review** is the one that counts. It runs in a fresh, scoped context.

Why the split matters: the model that wrote the code spent an hour reasoning its way to
the current design. Asked to review it, that reasoning is still in context and it will
mostly re-agree with itself. The subagent never saw the reasoning, only the result. That
is the entire point, and it is why the brief below is deliberately narrow.

A subagent rather than a new session, because findings need to come back into the main
context, where the design discussion still exists and can inform how to fix them.

---

## The subagent brief

Give the subagent exactly this, and nothing from the current conversation:

```
You are reviewing a pull request. You have no prior context on this project and you
should not assume the approach taken is correct.

Requirement: docs/requirements/BL-XXX.md
Architecture: architecture.md
Diff: [output of `git diff main...HEAD`]

Review against the checklist below. For every finding, give:
- the file and line
- what is wrong
- why it matters
- a proposed fix
- a severity: High, Medium, or Low, using the definitions given

Do not comment on style preferences the linter already covers. Do not suggest
refactors unrelated to this diff. If you find nothing at a severity, say so
explicitly rather than inventing findings to seem thorough.
```

That last sentence matters. A reviewer that feels obliged to produce findings will
produce noise, and noise trains the user to skim reviews.

## If your tool has no subagents

Do not skip the step. Use the closest available substitute, in this order:

1. **A named review agent or persona**, if the tool has one, given the same brief.
2. **A second session.** Open a new context, paste the brief and the diff, collect the
   findings, then bring them back to the working session for triage. Clumsier, but it
   preserves the property that matters: the reviewer never saw the reasoning.
3. **A different tool or model entirely.** Reviewing Claude's diff with Gemini, or the
   reverse, is a legitimate and often sharper version of this step.

What is never acceptable is asking the same context that wrote the code to approve it
and calling that a review. That is the self-check from the previous step, which you
have already done.

## The checklist

**Correctness**
- Does the diff actually satisfy every acceptance criterion in the requirement?
- Edge cases: empty input, very long input, special characters, duplicate submission,
  concurrent use.
- Off-by-one, null and undefined handling, timezone and date handling.

**Security**
- Any secret, key, token, or password in the code or in a committed file?
- Is user input validated before it reaches a database, a shell, or a template?
- Are errors leaking internal detail such as stack traces or file paths to the user?
- Is anything sensitive being logged?
- Does anything sensitive end up in client-side code, where it is public by definition?

**Data**
- Can this lose or corrupt existing data?
- Is a destructive operation reversible, or at least confirmed?
- Are migrations safe to run twice?

**Failure behaviour**
- What happens when the network, the API, or the database is unavailable?
- Does the user see something useful when it fails, or does it fail silently?
- Are the empty, loading, and error states from the journey document implemented?

**Fit**
- Does this contradict anything in `architecture.md`? If it does, either the code is
  wrong or the ADR is missing.
- Is this one backlog item, or has unrelated work crept in?
- Would a stranger reading this file understand what it does?

---

## Severity definitions

These are strict on purpose. Without definitions, a model under pressure to finish
rates things Low.

**High** - fix in this PR, no exceptions
- Any secret, key, or credential exposed
- An authentication or authorisation bypass
- Data loss or corruption on a normal path
- The core feature does not work
- A crash on ordinary use
- Unvalidated user input reaching a database, shell, or filesystem path

**Medium** - fix in this PR
- Wrong behaviour that has a workaround
- Unhandled error on a likely path
- Missing empty, loading, or error state on a screen users will see
- A performance problem on the main path
- An accessibility blocker such as no keyboard access or missing labels
- Anything touching secrets, auth, user data, or payments that is not already High

**Low** - fix only if the fix is small and stays inside files already in the diff
- Naming, formatting, comments
- Minor duplication
- A cosmetic UI inconsistency
- A refactor that would be nice

**The override, from rule 3:** anything touching secrets, authentication, user data,
payments, or data deletion is never Low. If it looks Low, rate it Medium and move on.
The cost of one unnecessary fix is minutes. The cost of a missed one can be the project.

## Triage

Triage happens in the main context, not in the subagent.

1. Read every finding. Confirm or reject the severity, and say why if you disagree.
   The reviewer lacks project context and can over-rate as well as under-rate.
2. Fix all High and Medium. In this PR.
3. Fix Low only if the change is small and confined to files already in the diff.
4. Everything unfixed goes to the Known issues table in `backlog.md` as `BUG-XXX`,
   with severity, the item it was found in, and enough description to act on later.
5. After fixes, run the verify command again. Fixes break things too.
6. Report to the user: what was found, what was fixed, what was deferred and why.

Never merge with an open High finding. Never silently drop a finding because it was
inconvenient. If a High finding is genuinely wrong, say so explicitly in the report
rather than quietly ignoring it.
