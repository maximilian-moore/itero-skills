---
description: Display project velocity, agent contributions, and token cost dashboard
---

Read `references/metrics.md`.

Display the multi-agent project metrics dashboard:

1. **Run the dashboard script:**
   ```bash
   ./scripts/metrics-summary.sh docs/project-metrics.md
   ```
2. If `docs/project-metrics.md` exists, summarize for the user:
   - Total features delivered to date.
   - Work breakdown by contributing agent and model.
   - Total lines added / deleted and test volume.
   - Estimated token consumption and cost trends.
3. If no metrics exist yet, explain that metrics are logged automatically whenever a PR
   completes the `/checkpoint` ritual.
