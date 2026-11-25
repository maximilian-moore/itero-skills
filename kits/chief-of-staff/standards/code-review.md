# Standard: code review

Used by Project Leads and their `reviewer` subagents, on any harness. It combines two things:

- **What to look for:** <OWNER>'s checklist and severity scale in <WORKFLOW_SKILL>
  `references/review.md` ("The checklist", "Severity definitions"), plus the stack add-on from
  `../skills.md`. That file wins every conflict.
- **How to look:** the find-then-verify method of Anthropic's official `code-review` plugin
  (Apache 2.0): several independent passes find candidates, then every candidate is checked
  again before it is reported. That keeps false positives out, and false positives are what
  make people stop reading reviews.

## Inputs

Paths, not contents: the diff or branch against its base, the requirement file, the repo's rules
file (`AGENTS.md` or `CLAUDE.md`), `architecture.md` (or equivalent), the stack, and the round number.

## Step 1: Find (independent passes)

Run each pass with fresh eyes. Where the harness has subagents or can start separate sessions, run them
as separate agents in parallel. Otherwise run them one after another and do not let one
pass's notes steer the next.

| Pass | Looks for | Model |
|---|---|---|
| A. Requirement | Every acceptance test in the requirement: is it met by the change? Missing empty, loading, error states from the journey. | strong |
| B. Bugs | Correctness, failure behaviour and data sections of the checklist, **in the changed code**. Also the security checklist items. | strong |
| C. Rules | Clear violations of the repo's rules file and `architecture.md`. Quote the exact rule. | cheap |
| D. Stack | The stack add-on checklist (Flutter, TypeScript, …), only for changed files. | cheap |

Each pass returns candidates: `file:line`, the problem, the reason it was flagged, a severity guess.

## Step 2: Verify (every candidate, separately)

For each candidate, a fresh check, ideally by a different agent than the one that found it:
1. Read the code around the line. Is the problem real?
2. Is it introduced or touched by this change? A problem the change does not touch goes to the
   backlog as a note, not into this review.
3. Can you state the concrete failure: what input or situation, what goes wrong?

Keep only confirmed findings. Then set the final severity from `review.md`'s definitions.
Rule 3 applies: anything touching secrets, auth, user data, payments or deletion is never Low.

## Not findings (drop these)

- Problems that existed before the change.
- Things the linter or type checker catches; the verify command covers them.
- Pedantic nits a senior engineer would not raise; style without a change in meaning.
- Something deliberately silenced in the code with a stated reason.
- Speculation you cannot back with a concrete failure.

Missing error, empty or loading states, and unmet acceptance tests **are** findings, even
though Anthropic's plugin skips general quality concerns. `review.md` asks for them.

## Size the effort to the item

| Item kind | Passes | Verify |
|---|---|---|
| Small fix | A and B in one agent | inline, same agent, re-reading each finding |
| Autonomous run, round 1 | A, B, C, D as separate agents | a separate verifier for each High and Medium |
| Autonomous run, round 2 | B only, on the fixes | inline |

## Output (max 40 lines)

```
verdict: pass | fix-needed
<High|Medium|Low> <file:line> <problem>. Failure: <when it breaks>. Fix: <one line>.
untested: <acceptance tests with no automated test>
dropped: <n candidates not confirmed>
```

## Optional extra while Claude Code is available

On a Claude Code lead, Claude's built-in `/code-review` may run **in addition**, for High-tier items.
Map its findings onto `review.md` severities and triage them with the rest. It never replaces this
standard, because other harnesses do not have it.
