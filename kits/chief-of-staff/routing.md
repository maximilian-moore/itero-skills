# Model routing & execution modes

`route` tiers decide which provider and model runs each role, and how HQ launches Project Leads
in your environment.

## Execution modes (pick what your harness supports)

| Mode | Launch a Project Lead | Resume / send answer |
|---|---|---|
| **Claude Code CLI** | `claude -p "<prompt>" --cwd <repo_or_worktree>` | `claude -p "<answer>" --resume <session_id>` |
| **Codex CLI** | `codex exec -C <repo_or_worktree> "<prompt>"` | `codex exec resume <session_id> "<answer>"` |
| **OpenCode CLI** | `opencode run --dir <repo_or_worktree> "<prompt>"` | `opencode run --dir <repo_or_worktree> --session <id> "<answer>"` |
| **Native Subagent** | Harness subagent tool (`Agent` with `isolation: "worktree"`, `spawn_agent`, etc.) | Message/resume that subagent |
| **T3 Code (optional)** | `t3_thread_launch` (or `t3 thread start`) | `t3_thread_send` |

For parallel tasks in the same repo without a built-in worktree tool, create one first:
`git -C <repo> worktree add ../<project>-<item> -b feat/<item>`

## Roles and tiers

| Tier | Role | Example models |
|---|---|---|
| `route` | Chief of Staff (coordinates, never builds) | Reasoning model (e.g. Claude Sonnet / Gemini Hydrogen / GPT) |
| `judge` | Planning, architecture, UI specs | High-reasoning model |
| `lead` | Project Lead (plans, delegates, merges PRs) | Balanced or high-reasoning coding model |
| `build` | Implementing a `ready` requirement in a worktree | Fast/strong coding model (plus local open-weights fallback) |
| `review` | Code & security review (**different model family from author**) | Cross-family high-reasoning model |
| `fast` | Exploration, Q-rounds, test-log digestion | Fast low-cost model |

## Rules

1. **Cross-family reviews:** The reviewer must come from a different model family than the author who wrote the code.
2. **Spec gate:** Only send an item to a fast `build` model once requirements + acceptance tests are clear and unambiguous.
3. **One writer per checkout:** Parallel writers use isolated git worktrees, never the same working tree simultaneously.
