# Handover: end a session so the next one starts cold and loses nothing

A long session gets expensive and starts to drift: every message re-reads a context
window full of old file dumps, and decisions from two hours ago fade. The cheapest fix
is a fresh session. The risk of a fresh session is that it starts without the knowledge
this one built up. A handover removes that risk.

A handover does three things, in this order:

1. **Brings the repository up to date.** The status file describes the project as it
   is now, and everything is committed and pushed.
2. **Writes `docs/handover.md`.** The session-specific context that has no other home,
   plus the restart prompt.
3. **Prints the restart prompt in the chat**, ready to paste into the next session.

Run it when the user asks for it, and offer it yourself when a phase or a backlog item
is finished, when the user says they are stopping, or when the session has grown long.

---

## Step 1: make the repository true

Before writing a single line of handover, the repository has to describe itself
accurately, because the next session trusts the files and nothing else.

- **Status file.** Update `project-status.md`: `Last updated`, `Where we are`, `Next
  step` (never empty), `Open decisions`, and `Gotchas`. Anything that cost more than ten
  minutes this session goes into Gotchas.
- **Backlog.** Every item touched this session has its real status. Out-of-scope ideas
  that came up are rows with status `idea`. The `Next up` list matches the next step.
- **Decisions.** Every decision the user made this session is written where it belongs:
  the requirement file, an ADR in `architecture.md`, or the relevant project document.
  A decision that exists only in the chat is lost at the handover.
- **Commit and push.** Nothing committed only locally, nothing merged only locally.
  If work is half-finished on a branch, commit it as work in progress and push the
  branch. Never hand over with uncommitted changes you made.
- **Open pull requests.** If a pull request is still open, say so and why.

Run `git status -sb` at the end. The working tree is clean and the branch is not ahead
of its upstream. If it is not, the handover is not finished.

## Step 2: write `docs/handover.md`

Use `assets/templates/handover.md`. One page, overwritten at every handover. Git keeps
the history, so there is no archive to maintain.

Rule 5 applies here more than anywhere: **every fact lives in exactly one file.** The
handover links to the status file and the backlog. It does not copy them. What it holds
is only what has no other home:

- **Written at:** date and the commit hash it was written at. The next session compares
  this hash with `HEAD` to know whether the repository moved since.
- **Where we stopped:** one or two sentences, including anything half-done.
- **Next action:** the single next step, the backlog ID, and how to start it. The same
  step as in the status file, never a different one.
- **Read first:** the files the next session needs, in order, and how much of each.
  Name the large files it should *not* read in full, with the line range or search term
  that finds the relevant part instead. This is where most of the token saving is.
- **Decided this session:** a short list, each with a link to where it is written down.
- **Waiting on the user:** questions asked and not answered yet, and checks the user
  still has to do by hand.
- **Watch out:** traps found this session that are not general enough for Gotchas, and
  tools or commands that worked (for example, how screenshots were taken).
- **Working agreements:** how the user likes to work, as links to wherever that is
  recorded. Copy nothing that already lives in a rules file or memory.

Then the **restart prompt** at the bottom of the file.

## Step 3: the restart prompt

The restart prompt is what the user pastes as the first message of the next session.
It is short, because everything it needs is in the repository:

```
Continue <project> in <absolute repo path>.
Run the session start ritual (/start): sync with GitHub, then read
docs/handover.md, project-status.md and backlog.md, in that order.
Next action: <backlog ID and one-line description>.
Before you start: <the one thing that most needs to be known, if any>.
Report where we are in three lines and wait for my go.
```

Rules for the prompt:

- **Five to ten lines.** It points at files; it does not contain them. A long prompt
  costs tokens in every message of the next session, and it drifts from the files.
- **An absolute path**, so it works from any directory and in any tool.
- **The same next action** as the status file and the handover. If the three disagree,
  fix the files first.
- **Ends with a question to the user**, so the next session cannot start working on a
  stale assumption before the user confirms.

Print the prompt in the chat inside a code block, and write the same text at the bottom
of `docs/handover.md`. Commit and push that file. Then tell the user it is safe to
clear the session or open a new one.

## Self-check before you finish

Answer each question with yes, or fix the gap:

1. Could a fresh session, with no access to this chat, start the next action without
   asking the user anything that this session already knew?
2. Is the working tree clean and pushed, with nothing committed only locally?
3. Do the status file, the backlog, and the handover name the same next step?
4. Is every decision from this session written in a file, not only in the chat?
5. Does the handover link to facts instead of copying them?
6. Is the restart prompt ten lines or shorter?

## At the start of the next session

The `/start` ritual reads `docs/handover.md` after syncing. If the commit hash in its
`Written at` line is not an ancestor of `HEAD`, or `HEAD` has moved past it, say so: the
handover may be outdated, and the status file and git log win over it.
