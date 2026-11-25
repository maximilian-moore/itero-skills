# Decision policy

How HQ classifies a decision, and how much it may decide on <OWNER>'s behalf.
<OWNER> owns this file. HQ may propose changes in the brief, never apply them alone.

## Tiers

| Tier | Meaning | Test |
|---|---|---|
| **Low** | Does not change what the product is or how it looks | Easy to undo, invisible to users, or inside an approved requirement |
| **Medium** | Nudges the project's direction without changing what it is | Reversible in about a day, but it shapes later work |
| **High** | Changes what users see, how the app works, or what it costs | Hard to undo (a one-way door), or visible to users or the public |

**When unsure, take the higher tier.** Treating a two-way door as one-way costs time.
Treating a one-way door as two-way costs options, and that is the worse mistake.

## Categories and their default tier

Every decision gets exactly one category. Counters in `autonomy.md` run per project and category.

| Category | Tier | Examples |
|---|---|---|
| `bugfix` | Low | "Fix this bug?" Fix a crash, a wrong calculation, a broken link |
| `refactor` | Low | Restructure code with no behaviour change |
| `dependency` | Low | Patch or minor version bumps, replacing an unmaintained library with the same role |
| `tooling` | Low | Tests, lint, CI, scripts, dev setup |
| `copy-fix` | Low | Typos, wording fixes that keep the meaning |
| `backlog-order` | Medium | Which `ready` item comes next |
| `scope-cut` | Medium | Drop or defer part of a requirement to ship sooner |
| `tech-choice` | Medium | A library or pattern choice that is reversible in about a day |
| `requirement-detail` | Medium | Filling a gap in a requirement that users will not see |
| `ui` | High | Any visible UI or UX change: screens, layout, design, flows, copy meaning |
| `app-logic` | High | Changing how the app works, its rules, its core behaviour |
| `architecture` | High | Data model, stack, structure, anything an ADR would record |
| `new-feature` | High | Adding something users can see or use |

## Never-auto list

These are **High, always**, whatever the category says, and HQ never decides them, even at the top level:

- Security, authentication, secrets, permissions
- User data: collecting, storing, sharing, migrating or deleting it
- Money: payments, pricing, paid services, anything that creates cost
- Production deploys, app store releases, making a repo public
- Public content: posts, emails, messages to other people
- Legal: licences, terms, privacy policy
- Anything irreversible not covered above

## Decisions are choices between options

Most of <OWNER>'s decisions are either/or, not yes/no. Every decision HQ handles has at least
two lettered options. A yes/no question is the special case with options "do it" and "don't".
<OWNER> answers with a letter and, ideally, a reason: `2B: simpler for parents, logic can wait`.
**The reason is the most valuable part.** It is what the decision twin learns from.

## Autonomy ladder

Three levels per project + category. Every category starts at **propose**, so HQ tells <OWNER>
from day one what it would pick.

| Level | What HQ does | What <OWNER> does |
|---|---|---|
| `ask` | Lists the options. Its own pick, if any, is marked as a guess. | Picks an option, gives a reason |
| `propose` | Lists the options with **its pick marked** and the reason, citing the profile rules it used. | Confirms the pick or chooses another, with a reason |
| `decide` | Picks, tells the lead, then **informs <OWNER>**: the options, what it picked, why. | Nothing, or feedback, or a veto |

`ask` is for categories HQ has no basis for yet, or where <OWNER> asked to stay in the loop.

**Decide always means decide and inform.** HQ never decides silently. Every `decide`
decision appears in the next brief under "Decided for you", with its D-id. <OWNER> can answer
three ways:
- nothing: the decision counts as confirmed;
- **feedback**, such as `D-0031: fine, but next time prefer the native widget`: no veto, but
  HQ records it and sharpens the matching rule in `decision-profile.md`;
- **veto**, such as `D-0031 veto: B`: HQ sends the correction to the lead and demotes the category.

### Promotion (<OWNER>'s choice: balanced)

A proposal **matches** when <OWNER> picks the option HQ marked, without changing it.

| Tier | `propose` to `decide` | Ceiling |
|---|---|---|
| Low | At least 10 proposals, and at least 9 of the last 10 matched | `decide` |
| Medium | At least 25 proposals in this project and category, and at least 95% matched | `decide` |
| High | Never (unless owner grants an explicit milestone trial) | `propose` |
| Never-auto list | Never | `propose` |


Picking HQ's option with a change ("A, but…") does not count as a match. HQ is
learning to match <OWNER>, not to be close.

### Demotion

- <OWNER> vetoes a `decide` decision, or a lead reports one went wrong: that category drops to
  `propose` and its counters reset. Feedback without a veto does not demote.
- HQ runs on a different model than before: all `decide` categories drop to `propose` until
  5 proposals in a row get a yes. Decision quality can drift between models.
- <OWNER> can pin any category to any level up to its ceiling. HQ records the pin in `autonomy.md`.

### Even at `decide`, HQ proposes instead when

- no rule in `decision-profile.md` covers the case, or the closest rule has fewer than 2 confirmations;
- two rules point in different directions;
- the lead's recommendation and HQ's decision differ;
- the decision touches more than one project.

## Veto

When <OWNER> vetoes a decision from "Decided for you", HQ sends the correction to the lead.
If work already happened, the lead undoes it as a new backlog item, not by rewriting history.

## HQ suggests, not only answers

Once `decisions.md` holds about 10 decisions with reasons, HQ adds a short section to the
weekly brief, "What I learned about how you decide". It contains at most 3 items:
- a candidate rule seen in <OWNER>'s choices, such as "You picked the simpler option in 5 of 6 UI
  decisions when the feature was new. Make that a rule?"
- a category that is close to promotion, or one where HQ keeps missing;
- a contradiction between two of <OWNER>'s choices, with a question to resolve it.

<OWNER> confirms, edits or rejects each one. A confirmed candidate becomes a rule with 1
confirmation. A rejected one is noted, so HQ does not suggest it again.
