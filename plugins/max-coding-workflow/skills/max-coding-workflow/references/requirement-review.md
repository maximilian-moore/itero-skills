# Planning: question rounds

A review of the requirement file, before any code exists. It applies to `autonomous`
items only. A `small fix` skips it; see `references/planning.md` for the two kinds.

The goal: an agent that reads only the requirement file can build the item alone, for
hours, without asking anything and without guessing. That is what makes a long
unattended run possible.

Why a fresh reader: the agent that wrote the requirement knows what it meant, so it
reads its own gaps as filled. A reader that has never seen the conversation finds them,
because it has to ask. Every question it asks is a choice the build agent would
otherwise have made on its own, and some of those choices go the wrong way.

What earlier projects showed:

- Most findings are mismatches with the existing code: a table named differently, a
  function that already exists, a rule the code already enforces otherwise. That is
  why the reader may search the codebase, and why the requirement is written when the
  code it builds on exists. Write it right before the build, not weeks ahead.
- Each round finds roughly half as many issues as the one before. A first round with
  thirty or forty findings is normal, not a sign of a bad file.
- A reader asked for questions always finds some. Waiting for zero wastes rounds, so
  the stop rule below is about severity, not count.

---

## Before round 1

1. Every section of `assets/templates/requirement.md` is filled, or says "None.".
2. The blockers in section 2 are `implemented`. If not, say so: the rounds would check
   the file against code that does not exist yet.
3. No open choice in the text: no TBD, maybe, probably, if needed, or similar, decide
   later, ask me. Run `scripts/check-requirement.sh docs/requirements/BL-XXX.md`: it
   finds those words, missing and empty sections, leftover template lines, gaps in the
   test numbers, and the size signals. It only warns; fix each warning or leave it on
   purpose. It costs nothing, so run it again after every round. Where the script
   cannot run, search the file for the words by hand.
4. Commit the draft. The rounds change it, and the first version is worth having.

## One round

1. **Brief a fresh reader.** A subagent, read-only, with the brief below and nothing
   from the conversation. A cheaper, faster model is fine here: the task is reading
   and asking, not designing. Each round gets a new reader, and no reader sees the
   findings of an earlier round, for the same reason as in code review: a reader told
   what to look for looks only there.
2. **Triage in the main context**, where the decisions behind the file are known. For
   each finding, one of three:
   - *The repository answers it.* Fix the file. Most findings end here.
   - *It is a real product decision.* Collect it. Do not decide it yourself.
   - *It is wrong.* The reader misread the file or the code. Note why, and check
     whether the wording invited the misreading; often it did, and a clearer sentence
     is the fix.
3. **Ask the user once, in one batch**, about the collected product decisions. Each
   question with the options and your recommendation, so the user can answer "yes"
   to most of them. Write each answer into section 4, with `user YYYY-MM-DD` as the
   source.
4. **Commit the round**: `docs(spec): BL-XXX question round N fixes`. If the session
   dies mid-way, the next one sees which rounds already ran.

## When to stop

A finding is **critical** when an agent that follows the file could build the wrong
thing, open a security or data-loss hole, or run into a contradiction with the code.
Everything else - a clearer word, a detail any builder would get right - is minor.

- Stop after the first round with no critical finding. Fix its minor findings that are
  quick, and leave the rest.
- At most four rounds. If round 4 still finds something critical, stop the rounds and
  tell the user what is open. Usually the item is too big or a decision is missing;
  the user decides whether to split it, decide the open point, or go ahead.

Write what the rounds taught into the Planning section of `learnings.md` - typically
the kind of gap the reader kept finding, so the next requirement avoids it from the
start (`references/learnings.md`).

Then record the rounds in the file's header (`Question rounds: 3 rounds: 21, 9, 2
findings, none critical in round 3`), set the item to `ready`, and commit.

---

## The brief

Give the reader exactly this, and nothing from the current conversation:

```
You are about to build a backlog item alone, for several hours, with nobody to ask.
Before you start, find everything you would have to ask.

Requirement: docs/requirements/BL-XXX.md
Architecture: architecture.md
You may also read the files the requirement names, and read and search the codebase.
Do not change any file.

List every question you would need answered to build this without guessing:
- a choice the file leaves open, or a place where two readings are possible
- an edge case or failure case with no stated behaviour
- a mismatch with the existing code: a name, a field, a rule, a function that is
  different from what the file says, or that already exists
- a contradiction between two parts of the file, or with architecture.md
- a test in section 9 that cannot be checked as written

For every finding give:
- the section and the sentence it is about
- the question
- what you would build if nobody answered, and why that could be wrong
- critical or minor: critical if building on your guess could give the wrong result,
  a security or data-loss hole, or a clash with the code

Do not suggest new features or scope. If you have no questions, answer exactly
"No remaining questions" rather than inventing findings to seem thorough.
```

## If your tool has no subagents

Do not skip the rounds, and do not let the agent that wrote the file answer its own
questions. Hand the brief over through a file instead:

1. Write the brief to `.review/BL-XXX-round-N-brief.md`. The `.review/` folder is in
   `.gitignore`; briefs and findings are working files, the fixes in the requirement
   are the durable part.
2. Start a second agent with no history - a new agent or chat in the same tool, or a
   different tool - and give it one line: "Follow `.review/BL-XXX-round-N-brief.md`
   and write your answer to `.review/BL-XXX-round-N-findings.md`." If it cannot write
   files, the user pastes its answer into that file.
3. Back in the working session, read the findings file and triage as above.

The same handover works for code review when there is no subagent.

## What it costs

A round reads the requirement and part of the codebase, and takes several minutes. The
rounds for one large item cost a share of a long run's budget. That is the price of a
run that does not stop to ask, and it is cheaper than a wrong build. It is also why a
`small fix` skips the rounds entirely, and why a cheaper model does the reading.
