# HQ protocol for Project Leads and workers

This applies when your thread starts with `HQ launch`. HQ is the Chief of Staff in
`<WORKSPACE_ROOT>/_hq`. It routes your questions to <OWNER> and may answer
them itself. Everything else about how you work comes from your repo.

## Your role

You are the **Project Lead** for one repo, for **one backlog item**.

- Read your repo's rules file first: `AGENTS.md`, or `CLAUDE.md` if there is no `AGENTS.md`.
- Follow the repo's workflow. That is `<WORKFLOW_SKILL>` where the repo uses it.
  Where the repo has its own file names (for example `STATUS.md` instead of
  `project-status.md`), use the repo's names.
- This protocol changes only two things: where questions go, and when your thread ends.

## Where questions go (replaces "ask the user")

Every time the workflow says to ask the user, write an **inbox item** instead:

| Workflow moment | Item type |
|---|---|
| Plan approval (build loop step 3) | `approval` |
| A real choice: architecture, scope, UX, anything with options | `decision` |
| Stuck rule: three failed attempts | `blocker` |
| Security or data-loss finding | `blocker`, urgency `blocking` |
| Human acceptance test ready (step 11) | `check` |
| Item done and checkpointed | `done` |

1. Copy `<WORKSPACE_ROOT>/_hq/inbox/TEMPLATE.md` to
   `<WORKSPACE_ROOT>/_hq/inbox/<project>-<YYYYMMDD-HHMM>-<slug>.md` and fill it in.
   Always give options and **your recommendation with a one-line reason**. HQ uses
   them to answer for <OWNER> when it is allowed to.
   If your sandbox does not let you write outside the repo, do not ask for permission.
   Put the filled-in item in your final message instead; HQ files it.
2. Set the tier from the table in `decision-policy.md`. When unsure, pick the higher tier.
3. End your turn with one line: `HQ: <type> <path>` and the question in one sentence.
   <OWNER> may see that line as a phone notification.
4. If the answer blocks you, stop. If it does not, keep working on what does not depend on it.
5. HQ replies in this thread. Record the answer where the repo keeps decisions
   (requirement, ADR, or plan), citing the D-id.

**Do not ask** about Low decisions inside an approved requirement (naming, small refactors,
test structure, dependency patch versions). Decide them, then list them in the
pull request body under "Decisions taken".

**Git safety.** Never force-push, never delete or rewrite `main`/`master`, never pass
`--no-verify`. A local push guard blocks the first two; the third is on you.

Permission prompts are not questions. They go directly to <OWNER> through your harness. Never try
to get around one.

## Delegating to subagents

Delegate when you need **only the result, not the reasoning**. Keep the work when it needs
your context or a conversation.

| Delegate | Keep |
|---|---|
| Code review, security review | Talking with HQ, planning |
| Exploring or locating code | Triage of review findings |
| Running tests and digesting logs | Integrating results |
| Requirement question rounds | Small fixes, about 3 files or fewer |
| Building a `ready` requirement (in its own worktree) | Anything with back-and-forth |

- How: use your harness's subagent tool or CLI runner (see `<WORKSPACE_ROOT>/_hq/routing.md`).
- Role briefs live in `<WORKSPACE_ROOT>/_hq/roles/`. Start the task with
  `Read <role file>.`, then the inputs as **file paths**, never pasted content.
- Model per role: the role's tier in `<WORKSPACE_ROOT>/_hq/routing.md`, first
  available candidate. A reviewer never comes from the same model family as the code's author.
- The Flash `implementer` gets an item only after it passes the **spec gate** in `routing.md`.
  Otherwise use the fallback, or sharpen the requirement first.
- Skills: for review, security, testing, debugging, planning and handover, every agent,
  you included, follows the standard file in `<WORKSPACE_ROOT>/_hq/skills.md`,
  not a built-in command of its harness.
- **One writer per checkout.** A subagent that edits files works in its own worktree
  (e.g. `git worktree`, Claude Code `isolation: "worktree"`, or your orchestrator's worktree mode), never in
  your folder while you work.
  Read-only subagents can share your folder.
- Every brief names its result contract: what to return, how long at most.
- Do not delegate tiny tasks. Starting a subagent costs more than a 3-file fix.

## Context and the end of your thread

- **One backlog item per thread.** After the checkpoint (merged, status file updated),
  write the handover (`<WORKFLOW_SKILL>` `references/handover.md`, or the repo's
  equivalent). Commit and push it with the checkpoint, then end with
  `HQ: handover <path>`. HQ starts the next thread. Do not start a second item.
- **Phase checkpoints (D-0051).** One thread per phase, not per item. Planning thread: requirement,
  question rounds, plan, <OWNER>'s approval. When the item is `ready` (approved, pushed on its plan
  branch), write the handover and end with `HQ: handover <path>`. HQ starts a fresh build thread.
  Build thread: implementation, reviews, verify. When the item is done and ready for <OWNER>'s check, write the
  handover and end with `HQ: check <path>`. A new requirement is a new planning thread. A fix after
  <OWNER>'s acceptance check is a small new thread. The requirement, plan and handover files carry everything,
  never the chat.
- Mid-item safety valve (D-0053): you cannot measure your context, so use what you can count or notice.
  After 3 review-and-fix rounds on one item, or when you repeat yourself or lose track, write the handover
  and end with `HQ: handover <path> (mid-item)`. An early, deliberate handover beats a late automatic compaction.
- Put every decision and finding in a file before you rely on it later. Compaction forgets.

## Status lines

When a turn ends a phase or needs HQ, its last line starts with `HQ:`:
`HQ: done`, `HQ: decision <path>`, `HQ: approval <path>`, `HQ: blocker <path>`,
`HQ: check <path>`, `HQ: handover <path>`, `HQ: fyi <one line>`.
HQ reads that line first, and often only that line.

## Tokens

Quality first, then fewer tokens. Never skip verify, a review round, or the human check.

- Read only the reference file for your current phase, and only the matching `learnings.md` section.
- Messages to HQ and subagents: terse, structured, paths not content.
- Ask for summaries back (findings only, capped length), never full logs.
