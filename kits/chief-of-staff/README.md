# Chief of Staff (HQ) — Starter Kit

A file-based multi-project orchestration setup for AI coding agents — **100% standalone and harness-agnostic** out of the box. Use it directly with **Claude Code**, **Google Antigravity (AGY)**, **Cursor**, **OpenAI Codex**, or **OpenCode** with zero external servers, cloud databases, or proprietary runtimes.

Instead of managing every project session manually, you talk to **one Chief of Staff (`_hq`)**. It routes tasks to Project Leads, collects questions in `inbox/`, learns your preferences in `decision-profile.md`, earns autonomy per project + category in `autonomy.md`, and gives you short briefs.

---

## Standalone Setup by Harness

HQ runs entirely on plain Markdown files and `git worktree` isolation. Choose the setup that matches your environment:

### 1. Claude Code (CLI or Native Subagents)
- **HQ Session:** Run `claude` inside your `_hq/` directory.
- **Dispatching Leads (CLI):** Launch a lead in a project or worktree non-interactively:
  ```bash
  claude -p "HQ launch. Project: <name>. First read <WORKSPACE_ROOT>/_hq/PROTOCOL.md..." --cwd /path/to/project
  ```
- **Dispatching Leads (Subagent):** Use Claude Code's native `Agent` tool with `isolation: "worktree"`.
- **Answering Questions:** Resume the lead session with `claude -p "<answer>" --resume <session_id>`.

### 2. Google Antigravity (AGY)
- **HQ Session:** Open the `_hq/` workspace in the Antigravity IDE or start `agy` in `_hq/`.
- **Dispatching Leads:** Dispatch project work using native subagents (`invoke_subagent` / `self` with `Workspace: "branch"` or `Workspace: "share"`), or background tasks targeting project directories.
- **Answering Questions:** Deliver decisions by messaging the subagent or updating the inbox file. Leads follow `PROTOCOL.md` and report back to `_hq/inbox/`.

### 3. Cursor (IDE & Composer)
- **HQ Session:** Open the `_hq/` folder as a dedicated workspace window. Talk to your Chief of Staff in Composer or Chat.
- **Dispatching Leads:** Open your project repos or git worktrees in separate Cursor windows. Paste the standard launch prompt into Composer (Agent mode).
- **Answering Questions:** When a lead hits an approval or choice, it writes to `<WORKSPACE_ROOT>/_hq/inbox/<project>-<slug>.md`. HQ in your `_hq/` window reviews it, applies your decision policy, and gives you a brief. You approve or adjust, and the lead continues.

### 4. OpenAI Codex
- **HQ Session:** Run `codex` inside `_hq/`.
- **Dispatching Leads (CLI):** Run `codex exec -C <repo_or_worktree> "<prompt>"`.
- **Dispatching Leads (Subagent):** Use Codex native `spawn_agent`.
- **Answering Questions:** Resume via `codex exec resume <session_id> "<answer>"`.

### 5. OpenCode
- **HQ Session:** Run `opencode` inside `_hq/`.
- **Dispatching Leads:** Run `opencode run --dir <repo_or_worktree> "<prompt>"`.
- **Answering Questions:** Resume via `opencode run --dir <repo_or_worktree> --session <id> "<answer>"`.

*(Note: If you use an external orchestrator like T3 Code, HQ also works via its thread tools, but no orchestrator is required.)*

---

## Parallel Work with Git Worktrees

To run parallel leads on the same repository without file collision, create an isolated git worktree for each task:

```bash
git -C /path/to/repo worktree add ../<repo>-<item> -b feat/<item>
```

When the lead finishes and its pull request merges, clean up the worktree:

```bash
git -C /path/to/repo worktree remove ../<repo>-<item>
```

---

## Quick Start

1. Place this folder as `_hq/` inside your main workspace (for example `~/DevProjects/_hq`).
2. Replace placeholders across files:
   - `<OWNER>` -> your name or handle
   - `<WORKSPACE_ROOT>` -> your workspace path (e.g. `/Users/you/DevProjects`)
   - `<GITHUB_OWNER>` -> your GitHub username/org
   - `<WORKFLOW_SKILL>` -> your per-repo coding workflow skill name (e.g. `max-coding-workflow`)
3. Update `routing.md` with your preferred harness mode and models.
4. Register your repos in `registry.md` (path, lead model/harness, and rules file).
5. Start a session in `_hq/` with your favorite agent (`claude`, `agy`, `cursor`, `codex`, `opencode`) and say `start` (or `brief`).

---

## How It Works

| File | Purpose |
|---|---|
| `AGENTS.md` / `GEMINI.md` / `CLAUDE.md` | Operating rules for the Chief of Staff (coordinates only, never codes in project repos) |
| `PROTOCOL.md` | Contract for Project Leads and subagents (where questions go, worktrees, handovers) |
| `decision-policy.md` | Low / Medium / High tiers, `never-auto` list, `ask` -> `propose` -> `decide` ladder |
| `decision-profile.md` | Your judgment rules learned over time from your answers |
| `autonomy.md` | Per-project + per-category proposal/match counters |
| `decisions.md` | Append-only decision log (`D-0001`, `D-0002`, ...) |
| `registry.md` | Project registry (paths, harness/session IDs, models, active items) |
| `routing.md` | Execution modes + model tiers (`route`, `judge`, `lead`, `build`, `review`, `fast`) |
| `skills.md` + `standards/` | Shared stack-neutral review, security, TDD, and debugging standards |
| `roles/` | Concise briefs for delegated subagents (`explorer`, `implementer`, `reviewer`, etc.) |
| `inbox/` | Structured option-based questions from leads (`TEMPLATE.md`) |
| `state.md` / `handover.md` | Rolling session memory across context resets |
| `ideas.md` | Parked ideas and priority order |
| `bin/` | Git push guard (`install-git-guard.sh`) and local token-usage script (`usage-by-project.py`) |
