# Phase 4: User journey and design

Three things get decided here, once per project:

1. **The thin journey** - who, what jobs, the key flows.
2. **The design direction** - how the product looks and feels, chosen from three
   directions the user can see in a browser, and written down as design tokens.
3. **The prototype** - optional but recommended when the interface matters: the screens
   of the key flows, clickable, in the chosen direction, before any app code exists.

Why so early: a wrong look is cheap to change in a mockup and expensive to change in a
built app. Every screen built on the wrong tokens has to be touched again. Getting the
direction and the main screens right before Phase 5 is the cheapest design work in the
whole project.

What stays out: screens for features that are not in the first release. Those get a
mockup when their item is planned (`references/planning.md`), not now, because they may
never be built.

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

## Does the interface actually matter?

Ask directly, then follow through, because the answer changes the rest of this phase.

**If it does not matter** (personal tool, only the user sees it), say so plainly. Skip
the directions and the prototype, pick a component library with its default look,
write those defaults down as the tokens, and move on. Do not push a design process onto
someone building a script with a form on top.

**If it matters** (people other than the user will see it, or the user has firm ideas
about how it should look), work through the two steps below.

## Step 1: Three design directions

Ask first what the user already has: brand colours, a logo, an app whose look they
like, dark or light, playful or plain. Then offer the choice:

- *"I have a design"* - use it. Write it down as tokens and build one showcase page
  from it so both of you see the same thing.
- *"Show me options"* - propose three directions.
- *"You decide"* - pick one direction yourself that fits the users and the jobs, build
  its showcase page, and say in one line why you chose it. The user can still change it.

Three directions that are actually different. Three shades of the same blue is no
choice. For each direction give:

- a name and a one-line feel ("Calm and clear", "Bold and playful", "Dense and
  professional")
- the reference feel: one or two existing apps it resembles
- the tokens: colours for light and dark, fonts, spacing base, radius, shadow
- who it suits, and the trade-off

Then build each as a page from `assets/templates/design-showcase.html`:
`docs/design/direction-a.html`, `-b`, `-c`. The template shows the parts every app has -
header and navigation, type sizes, buttons, cards, a form with an error, a table,
success and error messages, a loading state, an empty state, light and dark mode. Change
only its tokens block, its direction block and its sample words, which become the app's
own screen names and objects. The layout stays the same on purpose: the user compares
styles, not page structures.

The user opens the three pages in a browser and answers: one of them, a mix ("the
colours of A with the fonts of C"), or a style of their own. Build the mix as one more
page and confirm it.

When the direction is chosen, write its tokens into `docs/user-journey.md`. Without
written tokens every new screen drifts, and the app ends up with four greys and three
button styles.

```markdown
## Design tokens
Direction: A, Calm and clear - docs/design/style.html
Colours: background #0F1115, surface #1A1D23, text #E8EAED, muted #9AA0A6,
         accent #4F8CFF, danger #E5534B, success #3FB950 (dark; light in style.html)
Type:    Inter. Headings 600 weight, body 400. Sizes 32/24/18/16/14.
Spacing: 4px base scale (4, 8, 16, 24, 32, 48)
Radius:  8px for cards, 6px for buttons, full for pills
Library: shadcn/ui
Mode:    dark first, light optional later
```

Keep only
the chosen page, as `docs/design/style.html`, and delete the others; git keeps them.
The tokens in the journey document are the source; the style page is regenerated from
them whenever they change.

## Step 2: The prototype

Ask, with the recommendation first:

- **Prototype the key flows now** (recommended when the interface matters). One
  clickable HTML prototype in `prototype/`, in the chosen direction, with sample data.
  It covers the screens of the key flows and their empty, loading and error states.
  No backend, no real data, and its code is a reference, not the start of the app.
- **A design tool instead.** Claude Design, Google Stitch, Figma, v0 - use the prompt
  below. Good when the user prefers to iterate there.
- **No prototype.** Screens get a mockup per item when they are planned.

Mark every screen in the prototype with a comment: `<!-- SCREEN: Project list -->`. A
requirement then points at "prototype screen Project list", and the build agent finds
it by searching for the marker instead of reading the whole file.

Show the prototype in small batches - one flow at a time - and collect feedback per
batch. A whole app reviewed at once gets a few comments on the first screen and a
"looks fine" for the rest.

## The design tool handoff

When a design tool is used, produce a ready-to-paste prompt block. The journey document
already contains everything it needs.

```
Design a [mobile app / web dashboard] for [one-sentence description].

Users: [persona]
Key flow to design: [flow, as numbered steps]
Screens needed: [list]
For each screen show: default state, empty state, error state.

Style: [tokens - colours, type, spacing, radius]
Reference feel: [app the user named, or the chosen direction]
Platform: [iOS / Android / responsive web], [dark / light]

Do not include: [anything explicitly out of scope]
```

Give this to the user as a copyable block. Then wait. Implementation of anything
UI-heavy does not start until the user has approved the prototype, the mockups, or an
explicit decision to skip them.

## Approval gate

Phase 4 ends when the user confirms the journey document, the design direction and
its tokens, and - if one was made - the prototype. Then update `project-status.md`,
commit, and move to Phase 5.

If the user is impatient to start building, the honest framing is: this is the last
cheap moment to change your mind about how the thing works. After this, changes cost
code.
