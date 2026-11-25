# Chief of Staff (HQ) — Starter Kit

A file-based multi-project orchestration setup for AI coding agents — **harness-agnostic** out of the box. Use it with **Claude Code**, **Codex**, **OpenCode**, **Cursor**, **Antigravity**, or **T3 Code**.

Instead of managing every project session manually, you talk to **one Chief of Staff (`_hq`)**. It routes tasks to Project Leads, collects questions in `inbox/`, learns your preferences in `decision-profile.md`, earns autonomy per project + category in `autonomy.md`, and gives you short briefs.

## Works With Any Harness

HQ uses plain Markdown files and git worktrees — no proprietary runtime required:

| Mode | How HQ launches & replies to Project Leads | Best when |
|---|---|---|
| **Standalone CLI** | `claude -p ...` / `codex exec ...` / `opencode run ...` in each repo (or `git worktree`) | You use Claude Code, Codex, or OpenCode in a terminal |
| **Native Subagents** | Your harness's subagent tool (`Agent` with `isolation: "worktree"`, `spawn_agent`, etc.) | You run everything inside one editor or agent session |
| **Orchestrator (optional)** | T3 Code MCP tools (`t3_thread_launch`, `t3_thread_send`) or `t3` CLI | You use T3 Code across mobile + desktop |

See `routing.md` ("Execution modes") for exact commands.

## Quick Start

1. Place this folder as `_hq/` inside your main workspace (for example `~/DevProjects/_hq`).
2. Replace placeholders across files:
   - `<OWNER>` -> your name
   - `<WORKSPACE_ROOT>` -> your workspace path (e.g. `/Users/you/DevProjects`)
   - `<GITHUB_OWNER>` -> your GitHub username/org
   - `<WORKFLOW_SKILL>` -> your per-repo coding workflow skill name (or remove if you don't use one)
3. Update `routing.md` with your harness mode (Claude Code / Codex / OpenCode / Subagents / T3) and preferred models.
4. Register your repos in `registry.md` (path, lead model/harness, and rules file).
5. Start a session in `_hq/` with your favorite agent (`claude`, `codex`, `opencode`, etc.) and say `start` (or `brief`).

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
