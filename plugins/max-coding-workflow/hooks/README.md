# SessionStart hook

Claude Code only. Other environments (Claude Desktop, Antigravity, Cursor) have no
hook, which is why `SKILL.md` also tells the model to check repo state manually at the
start of every session.

## Install

Do this automatically during Phase 0, and when resuming a project that does not have
it yet. Show the user what you are adding before you write it.

```bash
mkdir -p .claude/hooks
cp <skill>/hooks/session-start.sh .claude/hooks/session-start.sh
chmod +x .claude/hooks/session-start.sh
```

Then merge `settings-snippet.json` into `.claude/settings.json`. If the file already
exists, merge the `hooks` key rather than overwriting the file, or you will wipe the
user's other settings.

Commit `.claude/settings.json` and `.claude/hooks/`. Committing them is the point:
the hook then works on every machine the user clones to, with no per-machine setup.
Keep `.claude/settings.local.json` out of git, that one is machine-specific.

## Verify

Start a new session in the repo. You should see the PROJECT STATE block. If you do
not, check that the script is executable and that the hook schema still matches the
current Claude Code documentation, since hook configuration has changed between
versions.

## What it does

- Prints branch, uncommitted changes, and the last 10 commits
- Prints `project-status.md` in full
- Flags the status file as stale if the newest commit is more than a day newer than
  the file's `Last updated` line

It only reports. It never writes, commits, or changes anything.
