# Phase 4: User journey and design

Two things get decided here, and only two. Resist doing more.

**Now, once:** the thin journey (who, what jobs, key flows) and the design tokens
(colours, type, spacing, component library).

**Later, per feature:** detailed screen design.

Designing every screen upfront reintroduces exactly the waterfall problem that
per-requirement implementation plans exist to avoid. You would be designing screens for
features that get deprioritised. The journey document is stable. Screens are not.

---

## The journey document

`docs/user-journey.md`. Keep it under two pages. Structure:

**Who** - one or two short personas. Not marketing personas. "Me, on my phone, on the
train, with one hand" is a better persona than a fictional demographic.

**Jobs** - what a person is trying to get done, phrased as an outcome, not a feature.
"Capture a thought before I lose it" rather than "a text input with a save button".

**Key flows** - three to five, no more. Each written as numbered steps from the user's
point of view, ending in the outcome.

```markdown
### Flow: Capture a note on mobile
1. Opens the app from the home screen
2. Lands directly on an empty input, cursor already active
3. Types, then taps Save
4. Sees the note appear at the top of a list, with a timestamp
5. Closes the app
Outcome: thought captured in under 10 seconds, no navigation required.
```

**Screens** - just a list of names and one line each. No layouts here.

**States** - for each screen: what does empty look like, loading, error, and success?
This is the most commonly skipped section and the most common source of an app that
feels broken. An AI agent will happily build only the success case unless told
otherwise.

## Design tokens

Decide these once, write them down, and reuse them everywhere. Without written tokens
every new screen drifts and the app ends up with four greys and three button styles.

```markdown
## Design tokens
Colours: background #0F1115, surface #1A1D23, text #E8EAED, muted #9AA0A6,
         accent #4F8CFF, danger #E5534B, success #3FB950
Type:    Inter. Headings 600 weight, body 400. Sizes 32/24/18/16/14.
Spacing: 4px base scale (4, 8, 16, 24, 32, 48)
Radius:  8px for cards, 6px for buttons, full for pills
Library: shadcn/ui
Mode:    dark first, light optional later
```

Ask the user for preferences here rather than inventing them. Concrete prompts that
get real answers: is there an app whose look you like? Dark or light? Playful or
plain? Do you have brand colours already?

## Does the interface actually matter?

Ask directly, then follow through, because the answer changes the whole phase.

**If it matters** (people other than the user will see it, or the user has firm ideas
about how it should look), recommend a design tool. Claude Design, Google Stitch,
Figma, v0. Generate mockups first, get them right, then build against them.

Reason to give the user: reworking a generated interface to match an idea in your head
is slower and more frustrating than describing that idea to a design tool first.
Mockups are cheap to change. Implemented components are not.

**If it does not matter** (personal tool, only the user sees it), say so plainly and
skip the mockups. Pick a component library, apply the tokens, and move on. Do not push
a design process onto someone building a script with a form on top.

## The design tool handoff

When mockups are wanted, produce a ready-to-paste prompt block. The journey document
already contains everything it needs.

```
Design a [mobile app / web dashboard] for [one-sentence description].

Users: [persona]
Key flow to design: [flow, as numbered steps]
Screens needed: [list]
For each screen show: default state, empty state, error state.

Style: [tokens - colours, type, spacing, radius]
Reference feel: [app the user named]
Platform: [iOS / Android / responsive web], [dark / light]

Do not include: [anything explicitly out of scope]
```

Give this to the user as a copyable block. Then wait. Implementation of anything
UI-heavy does not start until the user has approved either the mockups or an explicit
decision to skip them.

## Approval gate

Phase 4 ends when the user confirms the journey document and the tokens. Then update
`project-status.md`, commit, and move to Phase 5.

If the user is impatient to start building, the honest framing is: this is the last
cheap moment to change your mind about how the thing works. After this, changes cost
code.
