# Standard skills: one source per task, for every agent and harness

**Who:** Project Leads and the subagents they start. The Chief of Staff does no reviews,
tests or builds; it only routes.

Every lead or subagent doing one of these tasks follows **the same file**, whether it runs on
Antigravity, Codex, Claude Code, OpenCode or anything else. Same method, same checklist, same
severity scale, so findings from different models can be compared and triaged the same way.

How to use one: the brief says `Read and follow <path>`. Every harness can read a file, so
nothing has to be installed per tool, and a new tool works on day one.

Paths: `MCW` = `<WORKSPACE_ROOT>/agent-skills/skills/<WORKFLOW_SKILL>`,
`STD` = `<WORKSPACE_ROOT>/_hq/standards`.

## The map

| Task | Standard | Also read |
|---|---|---|
| Code review | `STD/code-review.md` (<OWNER>'s checklist + find-then-verify method) | its stack add-on: Flutter `STD/flutter-dart-code-review.md`, TypeScript `STD/typescript-review.md` |
| Security review (separate agent) | `STD/security-review.md` | `STD/security-and-hardening.md`: "Process: Threat Model First", "Security Review Checklist" |
| Supply chain (new dependency or script) | `MCW/references/security.md`, section "Every phase - Before installing or running anything from outside" | - |
| Requirement question round | `MCW/references/requirement-review.md` | - |
| Planning a backlog item | `MCW/references/planning.md` + `MCW/assets/templates/implementation-plan.md` | the spec gate in `routing.md` |
| Building | `MCW/SKILL.md` Phase 5, steps 5 to 7 | testing row below |
| Testing | `MCW/references/testing.md` (what to test, rules: **wins conflicts**) | `STD/test-driven-development.md` (how: red-green-refactor, Prove-It for bugs, good test design) |
| Debugging, before strike 3 | `STD/debugging-and-error-recovery.md`, from "The Stop-the-Line Rule" | - |
| Handover | `MCW/references/handover.md` | - |
| UI check | the requirement's acceptance steps + `MCW/references/ux-flow.md`, "Design tokens" | the harness's own browser, simulator, or device tool |

Severity is always `review.md`'s High / Medium / Low. Other scales (CRITICAL, WARNING, …) get
mapped onto it. Rule 3 of <WORKFLOW_SKILL> wins every conflict: security and data loss are never Low.

## Built-in skills of a harness

Claude Code's `/code-review`, `/security-review` and the `claude-security` plugin, Codex's `/review`,
and Antigravity's built-in skills are **not** the standard, because each exists in one harness only.
A lead may run one **in addition**, on a High-tier item, while that harness is available. Its
findings get mapped onto the standard's severities and triaged with the rest.

## Baseline on every harness

Installed globally on Claude Code (`~/.claude/skills`), Codex (`~/.codex/skills`) and
Antigravity (`~/.gemini/config/skills`), checked 2026-11-07: `caveman`, `ponytail`,
`karpathy-guidelines`, `skill-loader`, `start-memory`. No extra install needed.

Claude Code also loads the `addy-agent-skills` and `caveman` plugins, whose skills can trigger on
their own. The role briefs name the standard file explicitly to prevent that.

## Decisions behind the map (2026-11-07)

| Task | Chosen | Why, and what was not chosen |
|---|---|---|
| Code review | Own `code-review.md` = <OWNER>'s checklist + method of Anthropic's `code-review` plugin | The plugin's strength is its method (parallel finders, independent verification, no false positives), and the method is portable. Its own text assumes Claude Code and GitHub comments. Built-in `/code-review` is Claude-only. addy `code-review-and-quality`, ECC `code-reviewer`: other severity scales. |
| Security review | Own `security-review.md` + addy `security-and-hardening` | `claude-security` is proprietary and needs Claude Code's Workflow tool. ECC `security-review` is Next.js/Supabase-specific. addy's is stack-neutral (threat model, privacy, supply chain, AI). |
| Testing | `testing.md` + addy `test-driven-development` | `testing.md` decides *what* to test per project type and the hard rules; it has no step-by-step loop. addy's adds the loop, the Prove-It pattern for bugs (= your "failing test first"), and prefers real implementations over mocks (= your "mocks lie"). ECC `tdd-workflow` was not chosen: it forces 80% coverage on every change, is written for JavaScript (Jest, Supabase, Redis mocks) while two pilot projects are Flutter, and contradicts `testing.md`'s "do not build a test pyramid for a weekend script". |
| Debugging | addy `debugging-and-error-recovery` | Your workflow has none; it fits the stuck rule. |
| Flutter, TypeScript | ECC `flutter-dart-code-review`, ECC `typescript-reviewer` | Stack-specific checks the general checklist lacks. |
| Spec writing | your `planning.md` | addy `spec-driven-development` overlaps with a different file layout. |

Copies of third-party files, their licences, and what the HQ-written standards are based on: `standards/SOURCES.md`.
