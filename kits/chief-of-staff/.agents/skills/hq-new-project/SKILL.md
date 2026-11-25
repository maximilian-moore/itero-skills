---
name: hq-new-project
description: >
  Chief of Staff skill: set up a brand-new project end to end, with no manual steps for <OWNER>.
  Creates the folder and git repo, AGENTS.md wired to HQ, <WORKFLOW_SKILL> and any extra skills,
  ritual commands, starter scripts, a push guard, the private GitHub repo, an optional T3 project (if `t3` CLI is installed) and the
  HQ registry row, then starts the kickoff lead. Use when <OWNER> says "new project", "start a project",
  "set up <name>", or describes an idea they want built in a new repo.
---

# New project

You are the Chief of Staff. You run setup; you do not build. The script does the mechanical
work so it is the same every time and costs no tokens.

## 1. Collect (one message, only what you cannot default)

| Item | Default | Ask only if |
|---|---|---|
| Name (folder and repo) | from <OWNER>'s words: short, letters/digits/dashes | no clear name |
| One-line idea | from <OWNER>'s words | <OWNER> gave none |
| GitHub | `private` | never ask; `public` only when <OWNER> says so (never-auto list) |
| Extra skills | your pick from the idea (below) | - |

Extra skills: look in `<WORKSPACE_ROOT>/agent-skills/registry.json` and
`agent-skills/skills/`. Typical picks: a UI app gets `ui-design` (and `impeccable` lives in Claude's
global skills already); a presentation gets `<PRESENTATION_SKILL>`; a writing project gets
`anti-ai-writing-pattern`. Pick at most three. Tell <OWNER> what you picked; it is a Low decision.

## 2. Run the script

```bash
bash <WORKSPACE_ROOT>/_hq/.agents/skills/hq-new-project/scripts/new-project.sh \
  <name> --title "<Display name>" [--skills "a b"] [--github private]
```

It stops without changing anything if the folder exists and is not empty. Read its SUMMARY.
If a step failed (for example GitHub), report that step to <OWNER> with the exact error line and
continue with the rest; never retry a failed `gh repo create` blindly. Check first with
`gh repo view <name>`.

## 3. Record

- `registry.md`: the script added the row.
- `state.md`: add the project under open loops ("kickoff running").

## 4. Start the kickoff lead

Start a kickoff lead session in the new repo using the runner in `routing.md` (tier `judge`):

```
HQ launch. Project: <name>.
First read <WORKSPACE_ROOT>/_hq/PROTOCOL.md, then AGENTS.md.
Task: run /kickoff (<WORKFLOW_SKILL> Phases 1 to 4) for: <one-line idea>.
Phase 0 is done by HQ setup: repo, .gitignore, AGENTS.md, skills, ritual commands, push guard,
GitHub remote, starter scripts/verify.sh. Finish Phase 0 after Phase 3: secrets (.env.example,
docs/SETUP.md) and the stack's checks in scripts/verify.sh.
Exception to PROTOCOL: run the kickoff interview with <OWNER> directly in this thread, a few questions
at a time. Escalate everything else through HQ as usual.
```

## 5. Tell <OWNER> (three lines)

- What exists now: path, GitHub link, skills.
- "Kickoff interview is waiting in <thread link>. Answer there; it is the one thread you talk to directly."
- What you picked for <OWNER> (extra skills, private repo), so <OWNER> can say otherwise.
