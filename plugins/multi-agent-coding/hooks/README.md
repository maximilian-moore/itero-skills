# Multi-Agent SessionStart Hook

Prints the current multi-agent repository state upon session start:
- Current branch and tracking position
- Uncommitted working tree status
- Recent commits
- `project-status.md` summary
- Active in-flight tasks and claimed branches
- Recent repository learnings from `docs/learnings.md`

Only reports; never modifies the working tree or connects to the network.
