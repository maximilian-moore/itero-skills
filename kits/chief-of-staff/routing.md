# Model routing & execution modes

`route` tiers decide which provider and model runs each role, and how HQ launches and communicates with Project Leads in your environment.

## Execution modes (pick what your harness supports)

HQ is 100% standalone and file-based. It requires no shared daemon or proprietary runtime:

| Harness | Launch a Project Lead | Resume / send answer | Parallel isolation |
|---|---|---|---|
| **Claude Code** | `claude -p "<prompt>" --cwd <repo_or_worktree>` or native `Agent` | `claude -p "<answer>" --resume <session_id>` or resume subagent | `isolation: "worktree"` or `git worktree` |
| **Google Antigravity (AGY)** | `invoke_subagent` (`Workspace: "branch"` or `"share"`), or `agy` CLI | Message subagent or update inbox item | Branch/share workspace or `git worktree` |
| **Cursor** | Open project / worktree in separate window; run in Composer | Paste decision or save to `_hq/inbox/` | Separate window per `git worktree` |
| **OpenAI Codex** | `codex exec -C <repo_or_worktree> "<prompt>"` or `spawn_agent` | `codex exec resume <session_id> "<answer>"` | `git worktree` |
| **OpenCode** | `opencode run --dir <repo_or_worktree> "<prompt>"` | `opencode run --dir <repo_or_worktree> --session <id> "<answer>"` | `git worktree` |
| *Orchestrator (optional)* | *`t3_thread_launch` (or `t3 thread start`)* | *`t3_thread_send`* | *Worktree strategy* |

---

## Standalone details by harness

### Claude Code
Run your Chief of Staff in terminal inside `_hq/` (`claude`). To dispatch tasks to a Project Lead:
- **CLI Runner:** Execute non-interactively:
  ```bash
  claude -p "HQ launch. Project: <name>. First read <WORKSPACE_ROOT>/_hq/PROTOCOL.md..." --cwd /path/to/project
  ```
- **Interactive Lead:** Or open a second terminal tab in `/path/to/project` and paste the launch prompt.
- **Subagents:** In supported versions, use the native `Agent` tool with `isolation: "worktree"`.

### Google Antigravity (AGY)
Run your Chief of Staff in the `_hq/` workspace.
- **Subagents:** Launch Project Leads using `invoke_subagent` / `self` with `Workspace: "branch"`.
- **Protocol:** Project Leads load `PROTOCOL.md` and write questions to `_hq/inbox/`.
- **Coordination:** HQ reviews open inbox items, applies the decision policy, and responds directly.

### Cursor
Keep your Chief of Staff open in one Cursor workspace window (`_hq/`).
- **Project Leads:** Open each project checkout or worktree in its own Cursor window.
- **Composer:** Start the Project Lead in Composer (Agent mode) with the launch prompt.
- **Question Loop:** When the lead encounters a blocker or question, it writes to `<WORKSPACE_ROOT>/_hq/inbox/<project>-<slug>.md`.
- **Decisions:** HQ in `_hq/` analyzes the inbox item, produces the brief, and records the answer in `decisions.md`. You or HQ deliver the approved choice back to the project window.

### OpenAI Codex
Run `codex` in `_hq/`.
- **CLI Runner:** Dispatch with `codex exec -C <repo_or_worktree> "<prompt>"`.
- **Resume:** Provide answers via `codex exec resume <session_id> "<answer>"`.

### OpenCode
Run `opencode` in `_hq/`.
- **CLI Runner:** Dispatch with `opencode run --dir <repo_or_worktree> "<prompt>"`.
- **Resume:** Provide answers via `opencode run --dir <repo_or_worktree> --session <id> "<answer>"`.

---

## Parallel work with Git Worktrees

Whenever multiple agents or leads work concurrently on the same repository, create an isolated checkout:

```bash
git -C <repo> worktree add ../<project>-<item> -b feat/<item>
```

When work is merged, remove the worktree:

```bash
git -C <repo> worktree remove ../<project>-<item>
```

---

## Roles and tiers

| Tier | Role | Example models |
|---|---|---|
| `route` | Chief of Staff (coordinates, never builds) | High-reasoning model (e.g. Claude Sonnet / Gemini Hydrogen / GPT) |
| `judge` | Planning, architecture, UI specs | High-reasoning model |
| `lead` | Project Lead (plans, delegates, merges PRs) | Balanced or high-reasoning coding model |
| `build` | Implementing a `ready` requirement in a worktree | Fast/strong coding model (plus local open-weights fallback) |
| `review` | Code & security review (**different model family from author**) | Cross-family high-reasoning model |
| `fast` | Exploration, Q-rounds, test-log digestion | Fast low-cost model |

---

## Rules

1. **Cross-family reviews:** The reviewer must come from a different model family than the author who wrote the code.
2. **Spec gate:** Only send an item to a fast `build` model once requirements + acceptance tests are clear and unambiguous.
3. **One writer per checkout:** Parallel writers use isolated git worktrees, never the same working tree simultaneously.
