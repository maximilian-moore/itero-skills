# Adding a skill to this repository

Notes to self, and to anyone contributing. The install scripts discover skills
automatically, so adding one is four steps and no script changes.

## 1. Create the folders

```
plugins/<plugin-name>/
  .claude-plugin/plugin.json
  plugin.json
  skills/<skill-name>/
    SKILL.md
    references/     optional, detail loaded on demand
    assets/         optional, templates the skill copies into user projects
    scripts/        optional, helpers the skill runs
  commands/         optional, one .md per slash command
  hooks/            optional, hooks the plugin registers, plus a shell fallback
```

Plugin name and skill name are usually the same. They differ only when one plugin
bundles several skills, which is worth doing when the skills genuinely share commands
or hooks and pointless otherwise.

## 2. Write SKILL.md

Frontmatter needs `name` and `description`. The description is the whole trigger
mechanism in every tool here, so:

- front-load the use case and the words a user would actually type
- name the situations it covers and the ones it does not
- keep it under 1024 characters, Claude Code rejects longer

Keep the body small enough to stay in context for a whole session. Anything long or
phase-specific goes in `references/` and gets read when it is needed.

Stay vendor-neutral. Write "if your tool supports hooks", not "in Claude Code". A skill
here may run under Gemini or GPT. Host-specific mechanics are allowed in `commands/`,
`hooks/` and `install/` - just never in `SKILL.md` or `references/`, and the skill must
still work with none of them present.

## 3. Register it

**`.claude-plugin/marketplace.json`** - add an entry to the `plugins` array:

```json
{
  "name": "<plugin-name>",
  "displayName": "Human readable name",
  "source": "./plugins/<plugin-name>",
  "description": "One sentence.",
  "version": "1.0.0",
  "license": "MIT",
  "category": "workflow",
  "keywords": ["..."]
}
```

**`plugins/<plugin-name>/.claude-plugin/plugin.json`** - the Claude Code manifest.
Copy an existing one and edit it.

**`plugins/<plugin-name>/plugin.json`** - the Antigravity marker. Two fields, `name`
and `description`, plus the schema line.

**A hook, if the skill ships one.** Declare it in the same
`.claude-plugin/plugin.json`, under a `hooks` key, and reference the script through
`${CLAUDE_PLUGIN_ROOT}`:

```json
"hooks": {
  "SessionStart": [
    { "matcher": "startup|resume|clear",
      "hooks": [ { "type": "command",
                   "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.js\"",
                   "timeout": 10 } ] }
  ]
}
```

Two rules for any hook registered this way, both learned the hard way:

- **Write it in Node, not bash.** Hook commands run through the system shell, and a
  `.sh` path does not execute on Windows - it fails silently, which looks exactly like
  a working hook. Ship a `.sh` alongside it only as a fallback for hosts without plugin
  hooks.
- **Make it silent by default and incapable of throwing.** A plugin hook runs in every
  repository the user opens, so it must detect that it does not apply and print nothing,
  and it must swallow its own errors. A hook that throws degrades every session.

## 4. Document it

Add a row to the table at the top of `README.md`, and a section below it following the
same shape as the existing one: what problem it solves, what it gives you, how to use
it. That table is what people read first.

`AGENTS.md` and the install scripts need no changes.

## Before you push

```bash
claude plugin validate .
python3 -c "import json;json.load(open('.claude-plugin/marketplace.json'))"
bash -n install/*.sh
node --check plugins/*/hooks/*.js                   # if the skill ships a Node hook
./install/install-codex.sh <skill-name> --project   # in a scratch directory
```

If the skill ships a hook, run it by hand in two scratch directories: one where the
skill applies, and one where it does not. The second must produce no output at all.

Test the trigger for real: start a session in a scratch project and phrase a request
the way a user would, without naming the skill. If it does not activate, the
description is the problem, not the body.

## Releasing

Bump `version` in both the marketplace entry and the plugin manifest. Users of the
Claude Code marketplace stay on the cached copy until the version changes.
