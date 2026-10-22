# BL-XXX: [Title]

Status: draft | ready | implementation | implemented | cancelled
Run: autonomous
Value: High | Medium | Low
Effort: High | Medium | Low
Blocked by: -
Question rounds: - [e.g. "3 rounds: 21, 9, 2 findings, none critical in round 3"]

<!--
Written so an agent can build this alone, for hours, without asking anything.
Every section is required. Write "None." where a section does not apply, so a reader
can tell "nothing here" apart from "forgot this". Never write TBD, maybe, probably,
if needed, or similar, decide later. Each of those is a choice left open, and the
agent will make it for you. See references/requirement-review.md.
-->

## 1. What and why
[One paragraph in user language. What a person can do afterwards that they cannot do
now, and why that matters.]

## 2. Prerequisites
- [Backlog items that must be `implemented` first, by ID]
- [Manual steps the user does before the run: accounts, keys, settings. IDs and names
  only, the steps themselves live in docs/SETUP.md]

## 3. Scope
In:
- [What this item builds]

Out:
- [What it deliberately does not build, with backlog IDs where they exist]

## 4. Decisions already made
| Topic | Decision | Source |
|---|---|---|
| [What a builder would otherwise have to decide] | [The decision, exact numbers and names] | [user YYYY-MM-DD / ADR-00X / this file] |

## 5. Data, interfaces and architecture impact
[New or changed tables, fields, files, endpoints, configuration, external services.
Name the existing ones this builds on, exactly as they are called in the code.
Architecture impact: None. / Which ADR changes and why.]

## 6. Screens and states
[Per screen: where it is in the prototype or mockup, what it shows, and its empty,
loading, error and success states. Exact texts in quotes. "None." for no UI.]

## 7. Behaviour and rules
[What happens on each action, in order. Validation, limits, permissions, who can see
what. Exact numbers.]

## 8. Edge cases and failure cases
- [Empty input, very long input, duplicates, two users at once, network or service
  down, no permission, the thing was deleted meanwhile. For each: what happens.]

## 9. Acceptance criteria (named tests)
- `BL-XXX-T01` (end-to-end) [Observable behaviour, not implementation]
- `BL-XXX-T02` (integration) [At least one failure case]
<!-- Numbered from T01 without gaps. The level - unit, integration, end-to-end - comes
from the test stack in architecture.md (references/testing.md). Each ID appears in the
title of the automated test that proves it, so a search finds it. Add new tests at the
end. Name the stand-ins for external services in section 5. -->

## 10. Human acceptance test
[Numbered plain-language steps. No jargon. A person who has never seen the code should
be able to follow this and know whether it worked. About 15 steps at most.]

1. 
2. 
3. You should see ...

## 11. Evidence
[What the run shows the user afterwards: the screenshots to take, by name and state,
or test output. "None." for no UI.]

## 12. Documentation to update, and stop conditions
Documentation: [README.md, architecture.md, docs/... - which file, what changes]

Stop only when: [The reasons to end the run and wait for the user. Everything else is
decided by the file, or by the most conservative option, written down and the run
continues.]

## 13. Done when
- [Only things the agent can check itself: tests pass, verify passes, the pull request
  had its review rounds, the documentation is updated, the evidence exists]
