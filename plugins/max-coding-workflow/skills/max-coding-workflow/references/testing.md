# Phase 3: The test stack

The test stack is chosen with the rest of the architecture, recorded as an ADR, and
wired into `scripts/verify.sh` before the first feature is built. Tests are what let an
agent work alone for hours: every step it takes is checked by something other than
its own opinion of the result.

For a builder who is not a developer, tests matter even more than for a professional.
You cannot read the diff and see that something broke. The test run can.

---

## Three levels

| Level | Checks | Speed | Typical tools |
|---|---|---|---|
| Unit | one function or rule, alone | milliseconds | Vitest, Jest, pytest |
| Integration | several parts together: code plus a real database, an API route, a server action | seconds | the same runners, against a local database |
| End-to-end | the app in a real browser, as a person uses it | seconds to minutes per test | Playwright |

Use each level for what it is good at. Rules and calculations get unit tests. Anything
that touches the database or a permission gets an integration test, because that is
where mocks lie. The key flows from `docs/user-journey.md` get end-to-end tests,
because they are what the user will check by hand.

## What to recommend

Recommend by what the project is, then let the user overrule, as with every
architecture choice.

| Project | Recommend |
|---|---|
| Web app with a user interface | Unit and integration tests with the framework's usual runner, plus **Playwright** end-to-end tests for every key flow |
| API or backend without a UI | Unit tests, plus integration tests against a local copy of the real database |
| Command-line tool or script | Integration tests that run the tool on sample input and compare the output |
| Mobile app | Unit tests; end-to-end only if the user is ready for the extra setup, and say what it costs |
| Static site or landing page | A few Playwright checks: the pages load, the links work, the form submits |
| One-off script only the user runs | One or two tests of the part that would hurt if it were wrong. Do not build a test pyramid for a weekend script |

Playwright is the default for anything in a browser. It drives Chrome, Firefox and
Safari, runs in CI, emulates phone screens, and takes screenshots, which the human
check and the evidence section of a requirement use. Say so in one sentence when you
recommend it.

Record the choice as an ADR ("Test stack"), with what each level covers.

## What every project gets

**Named tests.** Each criterion in a requirement has an ID (`BL-XXX-T01`), and the test
that proves it puts the ID in its title:

```ts
test('BL-014-T03 an empty title shows "Give your project a name"', async ({ page }) => {
```

A search for the ID then shows whether every criterion has a test, and a reviewer can
check the list without reading the code.

**Test data that is not real data.** A seed script that fills a local database with
sample users and content, so every test run starts from the same known state. Never
test against production data, and never let a test delete data that is not seed data.

**Stand-ins for external services.** Email, payments, maps, AI APIs: in tests and
local runs they are replaced by a fake that records what would have been sent. A long
run then never stops for a missing key, and a test never sends a real email or charges
a real card. Write down in the requirement which stand-in replaces which service.

**Tests in the verify command.** `scripts/verify.sh` runs all of it. The end-to-end
tests can sit in their own script when they are slow, but they run before every review
and in CI, not just when someone remembers.

## Rules for writing tests

- Write the test with the code, not afterwards. A test written afterwards is written to
  match whatever got built, bugs included.
- For a bug, write the failing test first, then fix. The test proves the bug is gone and
  stays gone.
- Never weaken, skip or delete a test to get to green. If a test is wrong, fixing it is
  a decision the user hears about, with the reason. If the only way to green is
  weakening a test, stop and ask.
- Test what the user sees, not how the code is built. "The note appears at the top of
  the list" survives a refactor; "the store's array has length 1" does not.
- End-to-end tests find elements the way a person does: by role, label and visible
  text, not by CSS classes that change with the design.
- A flaky test is a bug. Fix it or quarantine it with a backlog item; never retry until
  it passes and move on. Tests that share a user or a row often clash when they run in
  parallel - give each its own data, or run that group one at a time.

## Screenshots as evidence

Where a requirement lists screenshots in its evidence section, an end-to-end script
takes them: each screen in each state, desktop and phone width, light and dark if the
app has both. The user then sees the result before testing it by hand, and a broken
screen shows up in a picture instead of in the user's afternoon. Screenshots are
output, not source: write them to a gitignored folder and link or attach them.

## Growing the stack

Start small in Phase 0: lint, a type check and one real test. Add integration tests
with the first database code, and Playwright with the first screen. A gate that always
passes is not a gate, and a gate that takes forty minutes gets skipped - keep the
verify run short enough that it runs every time.
