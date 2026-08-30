# Instructions for agents

This repository distributes agent skills. It contains no application code. If you have
been pointed at it, one of three things is being asked of you. Work out which, then
follow that section.

1. **Install a skill for the user** - most common. See below.
2. **Use a skill without installing it** - see "Running a skill directly".
3. **Edit or add a skill in this repository** - see "Working on this repository".

Ask the user which they want if it is genuinely ambiguous. Do not install anything
without saying what you are about to do.

---

## Installing a skill

### Step 1 - Find out what is available

```bash
ls plugins/*/skills/
```

Each directory under `plugins/<plugin>/skills/<skill>/` is one installable skill. Read
the YAML frontmatter of its `SKILL.md` for the name and description. The `README.md`
at the repository root lists them for humans.

### Step 2 - Work out which tool you are running in

Do not guess. Check, in this order:

| Signal | Tool |
|---|---|
| `~/.claude/` exists, or you support `/plugin` commands | Claude Code |
| `~/.codex/` or `~/.agents/skills/` exists, `codex` on PATH | OpenAI Codex |
| `~/.gemini/` or `.agents/rules/` exists | Google Antigravity |
| None of the above | Ask the user |

If you cannot determine the tool, ask. Installing into the wrong directory is silent
and the user will conclude the skill does not work.

### Step 3 - Install

**Claude Code.** Tell the user to run these two commands. You cannot run them yourself,
they are interactive slash commands.

```
/plugin marketplace add maximilian-moore/itero-skills
/plugin install <skill-name>@itero-skills
```

If the user prefers files in their own skills directory, or their version has no plugin
support, run the fallback script instead.

**Every other tool.** Run the matching script from the repository root:

```bash
./install/install-codex.sh [skill-name] [--project]
./install/install-antigravity.sh [skill-name] [--plugin]
./install/install-claude-manual.sh [skill-name] [--project]
```

With no skill name, every skill in the repository is installed. Pass one or more names
to install a subset. Default scope is all projects for Codex and Claude Code, and the
current project for Antigravity.

**A tool not listed here.** Find where it looks for skills. Most current tools use
`.agents/skills/` in the project or `~/.agents/skills/` for the user. Copy the skill
folder there:

```bash
cp -R plugins/<plugin>/skills/<skill> <target>/<skill>
```

The skill is plain markdown with no build step, so a copy is a complete install.

### Step 4 - Verify and report

Confirm the folder landed in the right place and that `SKILL.md` is directly inside it,
not nested deeper. Then tell the user, in plain language:

- which skills were installed
- the exact path they went to
- whether the scope is this project or all projects
- that a restart or new session is needed before the skill is visible
- how to trigger it

Do not claim an install succeeded that you did not verify.

### What not to do

- Do not install every skill when the user asked for one.
- Do not edit the user's config beyond what the install requires.
- Do not install hooks globally. Hooks in this repository are per project by design,
  and a skill installs its own hook into a target project when it needs one.
- Do not run install scripts without telling the user first.

---

## Running a skill directly

The user may want to use a skill once without installing it. That is fine. Read
`plugins/<plugin>/skills/<skill>/SKILL.md` and follow it.

Reference files under `references/` are read on demand, at the point the instructions
call for them, not all at once. Loading everything upfront wastes the context the
actual work needs.

---

## Working on this repository

### Layout

```
.claude-plugin/marketplace.json    the marketplace manifest, one entry per plugin
plugins/<plugin>/
  .claude-plugin/plugin.json       Claude Code manifest
  plugin.json                      Antigravity manifest
  skills/<skill>/SKILL.md          the canonical skill, plain markdown
  skills/<skill>/references/       detail, loaded on demand
  skills/<skill>/assets/           templates the skill copies into user projects
  skills/<skill>/scripts/          helper scripts the skill runs
  commands/                        slash commands, for tools that have them
  hooks/                           optional per-project hooks
install/                           one script per host tool
docs/                              human documentation
```

The copy under `skills/` is canonical. Every install path points at it. Never fork a
second copy for a different tool.

### Rules for skill content

**Stay vendor-neutral.** A skill here may run under Claude, Gemini or GPT, in Claude
Code, Codex, Antigravity, or a plain chat window. Instructions phrased as "do X, then
Y, produce Z" travel anywhere. Instructions that assume a particular model's output
format, context limit, reasoning style or tooling do not. Anything vendor-specific
belongs in `commands/`, `hooks/` or `install/`.

**Degrade, do not skip.** Where a step depends on a capability not every tool has, such
as subagents, write the fallback into the reference file rather than letting the step
be dropped.

**Frontmatter is the trigger.** Every tool here matches skills on the `description`
field. Front-load the use case and the words a user would actually type. Keep it under
1024 characters.

### Adding a skill

See `docs/ADDING-A-SKILL.md`. In short: create the plugin folder, add an entry to
`.claude-plugin/marketplace.json`, add a row and a section to `README.md`. The install
scripts discover skills automatically and need no changes.

### Before committing

```bash
claude plugin validate .                        # if Claude Code is available
python3 -c "import json;json.load(open('.claude-plugin/marketplace.json'))"
bash -n install/*.sh
```

Bump the `version` in the plugin manifest and the marketplace entry on every release,
or existing users keep the cached copy.
