# SessionStart hook

Prints the current repo state into a new session so the model orients itself before
doing anything: branch, upstream position, uncommitted changes, recent commits,
`project-status.md`, and the backlog's `Next up` list.

It only reports. It never writes, commits, or changes anything.

## Two files, two hosts

| File | Used by | How it is installed |
|---|---|---|
| `session-start.js` | Claude Code | Registered automatically by the plugin |
| `session-start.sh` | Anything with shell hooks | Copy it into the project by hand |

`session-start.js` is the canonical one. It is Node rather than bash because plugin
hook commands run through the system shell, and a `.sh` path silently fails to execute
on Windows - which is exactly how this hook came to look like it worked while doing
nothing. Node is always present, because the host that runs the hook runs on it.

## Claude Code: nothing to install

`.claude-plugin/plugin.json` declares it:

```json
"hooks": {
  "SessionStart": [
    {
      "matcher": "startup|resume|clear",
      "hooks": [
        { "type": "command", "command": "node \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start.js\"" }
      ]
    }
  ]
}
```

Installing the plugin installs the hook, in every repository, with no per-project setup
and nothing to commit.

**It stays quiet where it is not wanted.** The script exits without printing anything
unless the working directory is a git repository containing `project-status.md` or
`backlog.md`. That check is what makes global registration safe: a project state block
never appears in an unrelated repository, and there is no nag telling you to adopt the
framework in repos where you have not chosen to.

## Other tools

Antigravity, Codex and Claude Desktop use different hook formats, or have none. There is
no port that covers all of them, so the honest answer is: type `/start` instead. It does
everything this hook does and more.

If your tool does run shell hooks, copy the shell version into the project:

```bash
mkdir -p .claude/hooks
cp <plugin>/hooks/session-start.sh .claude/hooks/session-start.sh
chmod +x .claude/hooks/session-start.sh
```

Then register it in whatever format that tool uses. `settings-snippet.json` is provided
for reference, but it is Claude-Code-shaped: it is the right answer only for a manual
Claude Code install, where you merge its `hooks` key into `.claude/settings.json` rather
than overwriting the file. Antigravity's `hooks.json` and Codex's configuration are
different shapes and the snippet does not apply to them.

## The hook is never load-bearing

Every tool here works without it, because `/start` does the same reading and more - it
also fetches from the remote, pulls when it is safe to, and checks that the backlog and
the status file agree. The hook is a convenience that front-loads the read; `/start` is
the ritual. `SKILL.md` tells the model to run the `/start` steps regardless of whether
a hook fired.

## Verify it works

Open a session in a repo that has a `project-status.md`. You should see the
`PROJECT STATE` block. Open one in a repo that does not, and you should see nothing at
all - that silence is the feature, not a failure.

To test the script directly:

```bash
node plugins/max-coding-workflow/hooks/session-start.js
```
