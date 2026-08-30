# Itero Skills

Agent skills for building things with AI when you are not a professional developer.

Everything here follows the open Agent Skills standard, so it works in Claude Code,
OpenAI Codex, Google Antigravity, and anything else that reads a `SKILL.md`.

Built by [Max Moore](https://itero-digital.com).

---

## The skills

| Skill | What it does | Status |
|---|---|---|
| [`max-coding-workflow`](#maxs-ai-coding-framework) | A repo-first process for building software with an AI coding agent | v1.0.0 |

More are coming. Each one lives in its own folder and installs independently, so you
can take one without taking all of them.

---

### Max's AI Coding Framework

`max-coding-workflow`

Seven phases, five rules, and a set of documents that live in your repository instead
of in the chat window.

The problem it solves: AI can write the feature. What it cannot do is remember, three
sessions later, why you chose SQLite, what half the files do, or which of the three
login flows is the real one. Context windows die. Files in git don't.

**What it gives you**

- A kickoff interview that forces the four decisions which are cheap now and expensive
  later: where it runs, who can access it, where data lives, what it costs
- A backlog split into a scannable index and per-item requirement files
- An architecture file with a decision log, so a fresh session can reconstruct the why
- One implementation plan per feature, approved before any code gets written
- Independent code review with severity definitions that cannot be talked down
- A checkpoint after every merge, so you can stop mid-project without losing anything
- Secrets handled properly from day one, and a history scan before you go public

**The five rules**

1. One pull request equals one backlog item. Everything else goes to the backlog.
2. Nothing merges without: verify, independent review, human acceptance test, status update.
3. Security and data loss are never rated low priority.
4. Three failed attempts at the same problem, then stop and ask.
5. Every fact lives in exactly one file. Duplicated docs drift and lie.

**What it creates in your project**

```
your-project/
  README.md              what it is, how to run it
  project-status.md      one page: where you are, what is next
  backlog.md             index of every item, plus known issues
  architecture.md        the stack, and the log of why
  .env.example           every secret key, no values
  docs/
    SETUP.md             where to get each secret, per machine
    user-journey.md      flows, screens, design tokens
    requirements/        one file per ready backlog item
    plans/               disposable per-feature plans
  scripts/
    verify.sh            the merge gate
    scan-secrets.sh      history scan before going public
```

**Using it.** Start a project and say what you want to build. The skill sets up the
repository, interviews you, builds the backlog, proposes an architecture, and then
works one backlog item at a time. Four rituals repeat: kickoff, plan, review,
checkpoint. In Claude Code they are slash commands. Elsewhere the agent runs them on
its own at the right moment.

---

## Install

### Claude Code

```
/plugin marketplace add maximilian-moore/itero-skills
/plugin install max-coding-workflow@itero-skills
```

Updates arrive when a version is bumped. `/plugin marketplace update itero-skills`
pulls them immediately.

### Every other tool

```bash
git clone https://github.com/maximilian-moore/itero-skills.git
cd itero-skills
```

Then run the script for your tool. With no arguments it installs every skill in this
repository. Pass a skill name to install just one.

```bash
./install/install-codex.sh                        # Codex, all projects
./install/install-codex.sh --project              # Codex, this repo only

./install/install-antigravity.sh                  # Antigravity, this project
./install/install-antigravity.sh --plugin         # Antigravity, all projects

./install/install-claude-manual.sh                # Claude Code without the marketplace
```

### Anything else

A skill here is a folder of plain markdown with no build step, so copying it is a
complete install. Most tools now look in `.agents/skills/` for the project or
`~/.agents/skills/` for the user.

```bash
cp -R plugins/max-coding-workflow/skills/max-coding-workflow ~/.agents/skills/
```

For a chat interface with no skill support at all, paste `SKILL.md` into the
conversation and point the model at the reference files as it asks for them.

Detail and troubleshooting: [docs/INSTALL.md](docs/INSTALL.md).

### Letting an agent do it

Point your agent at this repository and ask it to install a skill. It reads
[AGENTS.md](AGENTS.md), which tells it how to detect your tool and which script to run.

---

## Portability

Skills here are written to be model-agnostic. They may run under Claude, Gemini or GPT.
Anything vendor-specific lives in `commands/`, `hooks/` or `install/`, never in the
skill itself.

Where a step depends on a capability not every tool has, the skill degrades rather than
skipping. `max-coding-workflow` needs an independent code review pass, which is a
subagent in Claude Code. Where subagents are not available, its `references/review.md`
gives fallbacks in order of preference. Reviewing one model's diff with a different
model is a legitimate and often sharper version of that step.

**Hooks are the exception.** The session-start hook shipped with
`max-coding-workflow` is written for Claude Code and installs into a target project,
not globally. Other tools have their own hook formats, Antigravity uses a `hooks.json`,
so port it yourself or run the session-start steps by hand. The skill works without a
hook; the hook just saves you the manual check.

---

## Repository layout

```
.claude-plugin/marketplace.json    marketplace manifest, one entry per plugin
plugins/<plugin>/                  one folder per plugin
  skills/<skill>/SKILL.md          the canonical skill
  commands/                        slash commands, where supported
  hooks/                           optional per-project hooks
install/                           one script per host tool
docs/                              install guide and contributor notes
AGENTS.md                          how an agent should install from this repo
```

## Contributing

Issues and pull requests welcome, particularly install support for tools not covered
here. If you want to add a skill, see [docs/ADDING-A-SKILL.md](docs/ADDING-A-SKILL.md).
Keep skill content vendor-neutral.

## Licence

MIT. See [LICENSE](LICENSE).
