# Install and troubleshooting

## Where the skills actually live

One canonical copy of each, at:

```
plugins/<plugin>/skills/<skill>/
```

Every install path below copies or registers those folders. If you edit a skill, edit
it there and reinstall.

List what is available:

```bash
ls plugins/*/skills/
```

All three install scripts take the same shape. With no skill name they install
everything in the repository; pass one or more names for a subset.

```bash
./install/install-<tool>.sh [skill-name ...] [scope-flag]
```

## Claude Code

**Marketplace (recommended).**

```
/plugin marketplace add maximilian-moore/itero-skills
/plugin install <skill-name>@itero-skills
```

If the install summary says to run `/reload-plugins`, run it. Slash commands installed
this way are namespaced, so they appear as
`/max-coding-workflow:plan` rather than `/plan`.

**Test a local checkout before pushing changes:**

```
/plugin marketplace add ./path/to/itero-skills
claude plugin validate .
```

**Hooks come with the plugin.** `max-coding-workflow` declares a SessionStart hook in
its `plugin.json`, so installing the plugin installs the hook. There is nothing to copy
and nothing to commit.

It does not print a project state block in unrelated repositories: the script exits
silently unless the working directory is a git repository containing
`project-status.md` or `backlog.md`. It is written in Node rather than bash, because
hook commands run through the system shell and a `.sh` path does not execute on Windows.

Other tools use their own hook formats, Antigravity has a `hooks.json`, so the hook does
not port automatically. Copy `hooks/session-start.sh` into the project by hand there, or
just type `/start`, which does everything the hook does and more. Every skill here works
without its hook.

## OpenAI Codex

Codex reads skills from `.agents/skills`, walking up from the working directory, so a
personal install at `~/.agents/skills` is available everywhere.

```bash
./install/install-codex.sh                     # every skill, all projects
./install/install-codex.sh max-coding-workflow # one skill
./install/install-codex.sh --project           # into this repository only
```

Confirm with `/skills` in a new session. Invoke explicitly with `$skill-name`, or let
Codex select it when a task matches the description.

Codex can alternatively be pointed at a `SKILL.md` path directly in
`~/.codex/config.toml`. Restart Codex after changing that file.

## Google Antigravity

Antigravity also uses `.agents/skills`, with `.agent/skills` kept for backward
compatibility.

```bash
./install/install-antigravity.sh                      # every skill, this project
./install/install-antigravity.sh max-coding-workflow  # one skill
./install/install-antigravity.sh --plugin             # all projects, as a CLI plugin
```

Restart Antigravity, then run `/skills`. Activation is implicit and driven by the
description field, same as the other tools.

Note that Antigravity may run a skill under Gemini rather than Claude. Skills here are
written to be model-agnostic for exactly this reason. If you fork and edit one, keep it
that way.

## Letting an agent install it for you

Point your agent at this repository and ask. `AGENTS.md` at the root tells it how to
detect which tool it is running in, which script to run, and what to report back.

## Verifying an install worked

Do not check that the files exist. Check that the skill triggers. Phrase a request the
way a user would, without naming the skill.

For `max-coding-workflow`, in a project with no `project-status.md`:

> Let's start a new project.

If it loaded, the agent sets up a repository and starts interviewing you rather than
writing code. If it starts writing code, the skill did not trigger. Check that the
folder is in the right place, that `SKILL.md` sits directly inside it rather than
nested deeper, and that the YAML frontmatter parses.

## Common problems

**The skill never triggers.** Triggering runs on the `description` field. Confirm the
frontmatter is valid YAML and that the file is at `<skill-folder>/SKILL.md`, not
nested deeper.

**Slash commands collide.** The manual Claude Code install copies every command file
into your commands directory unnamespaced - for `max-coding-workflow` that is `start`,
`kickoff`, `plan`, `implement`, `review` and `checkpoint`. If you already have commands
by those names, use the marketplace install instead, which namespaces them, or rename
them.

**The session-start hook does not fire after a manual install.** Only the marketplace
install registers it, because registration lives in the plugin manifest that the manual
script does not copy. Type `/start` instead; it does everything the hook does and more.
See "Hooks come with the plugin" above.

**The agent skips the review step** (`max-coding-workflow`). It needs a way to run an
independent pass. See the fallbacks in `references/review.md`. Do not let it
self-approve.

**Updates are not arriving in Claude Code.** Plugins are pinned by their `version`
field. Run `/plugin marketplace update itero-skills`. If you forked this and are
pushing changes, bump `version` in both `.claude-plugin/plugin.json` and the
marketplace entry on every release, or users keep the cached copy.

**A skill name is not found by an install script.** The scripts search
`plugins/*/skills/` for a directory matching the name you passed. Run
`ls plugins/*/skills/` to see the exact names.
