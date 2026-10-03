# Project Metrics, Velocity & Cost Tracking

Building with multiple agents and models requires visibility into effort, throughput,
and cost. Without metrics, teams cannot determine whether a complex agent workflow
is delivering high velocity or just generating high API bills.

Metrics are recorded systematically in `docs/project-metrics.md` after every merged PR.

---

## 1. The Metrics Log (`docs/project-metrics.md`)

```markdown
# Project Metrics Log

| Date | Item | Title | Contributor / Agent | Model | Duration | Files | Lines +/- | Tests Added | Tokens / Est. Cost |
|---|---|---|---|---|---|---|---|---|---|
| 2026-10-01 | BL-001 | User authentication | agent-claude | Claude 3.7 Sonnet | 35m | 5 | +180/-12 | 8 | ~65k / $0.45 |
| 2026-10-02 | BL-003 | Session store | agent-antigravity | Gemini 3.8 Flash | 18m | 3 | +95/-5 | 4 | ~40k / $0.04 |
| 2026-10-03 | BL-004 | CSV Export | max | Human | 45m | 2 | +50/-2 | 3 | - |
```

---

## 2. Automated Data Extraction at `/checkpoint`

During the checkpoint ritual, the Orchestrator extracts deterministic metrics using git:

```bash
# 1. Files and Lines Changed
git diff --stat origin/main...HEAD | tail -1
# Output example: "4 files changed, 145 insertions(+), 8 deletions(-)"

# 2. Count of Tests Added
git diff origin/main...HEAD | grep -E "^\+\s*(it|test|describe|def test_)\(" | wc -l

# 3. Branch Duration
# Compare timestamp of first branch commit against current time
FIRST_COMMIT_TIME=$(git log --reverse --format=%ct origin/main..HEAD | head -1)
CURRENT_TIME=$(date +%s)
DURATION_MINS=$(( (CURRENT_TIME - FIRST_COMMIT_TIME) / 60 ))
```

### Agent & Model Attribution:
- **Contributor / Agent:** Defaults to the git author or the actor ID claiming the task
  (e.g. `agent-alpha`, `user-max`).
- **Model:** The primary LLM used during implementation (e.g. `Claude 3.7 Sonnet`,
  `Gemini 3.8 Flash`, `GPT-4o`).
- **Tokens / Cost:**
  - Where the host tool provides exact session usage (e.g. Claude Code summary or
    Antigravity stats), record the reported token counts and cost.
  - Where exact telemetry is unexposed, record duration and diff size as the effort
    proxy, or estimate using the model's standard token rate.

---

## 3. The Dashboard Script (`scripts/metrics-summary.sh`)

The repository includes a standalone script `scripts/metrics-summary.sh` that parses
`docs/project-metrics.md` and prints a terminal dashboard:

- **Total PRs Shipped** (overall and by contributor)
- **Velocity Breakdown** (lines added/deleted, tests created per feature)
- **Model Distribution** (work allocation across Claude, Gemini, OpenAI, Human)
- **Cumulative Estimated Spend**

Users and orchestrator agents can invoke this via the `/metrics` ritual at any time.
