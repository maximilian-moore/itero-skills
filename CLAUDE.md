# Working in this repository

This is the **authoring repository** for the itero-skills marketplace. It distributes
agent skills. It contains no application code.

## Do not apply max-coding-workflow to this repository

`max-coding-workflow` is a product shipped from here, not a process to run here. This
overrides any global instruction to load that skill at the start of every session,
including one in a user-level `CLAUDE.md`. In this directory, do not load it, and do not
run `/start`, `/kickoff`, `/plan`, `/implement`, `/review` or `/checkpoint` as framework
rituals.

Reasons, in order of how much trouble each saves:

- **The artifacts do not belong here.** `project-status.md`, `backlog.md`,
  `architecture.md`, `docs/requirements/`, `docs/plans/` are files the skill writes into
  a *user's* project. In this repo they would sit next to the templates they were
  generated from, and anyone cloning it could not tell the example from the product.
- **This repository is public.** Every file here is documentation of how the skills
  work. Session state, half-finished plans and status notes are not.
- **The framework does not fit the work.** There is nothing to build, verify or merge
  behind a test suite. Editing a skill means editing prose.

The skill's SessionStart hook already stays silent here, because it prints nothing
unless the working directory contains `project-status.md` or `backlog.md`. Do not add
those files to make it fire.

If you are testing that the skill works, do it in a scratch repository outside this one,
never by adopting the framework in place.

## What to do instead

Read `AGENTS.md`. It covers the three things anyone asks of this repository - installing
a skill, running one without installing, and editing one - plus the layout and the rules
for skill content. `docs/ADDING-A-SKILL.md` covers adding a new skill.

The working conventions that do apply here:

- One change per branch and per PR, with a clear message. That is ordinary git hygiene,
  not the framework.
- `claude plugin validate .` must pass before anything merges.
- Bump the version in **both** `.claude-plugin/marketplace.json` and the plugin's
  `.claude-plugin/plugin.json` when a plugin changes. They are two files and they drift.
- Skill content stays vendor-neutral. Anything specific to one host tool belongs in
  `commands/`, `hooks/` or `install/`. See the rules in `AGENTS.md`.
- The copy under `skills/` is canonical. Never fork a second copy for a different tool.
