---
id: <project>-<YYYYMMDD-HHMM>-<slug>
project: <project>
from: <lead thread link>
type: decision        # decision | approval | blocker | check | done
tier: Medium          # Low | Medium | High (see decision-policy.md; when unsure, higher)
category: scope-cut   # one category from decision-policy.md
urgency: today        # blocking | today | whenever
refs: BL-000, docs/requirements/BL-000.md
status: open          # open | closed
---

**Question:** <one sentence>

**Options:**
- A) <option> · <cost or effect>
- B) <option> · <cost or effect>

**Recommendation:** A, because <one line>.

**If no answer:** <what the lead does meanwhile: waits, or continues with X>

<!-- For type check: numbered plain-language acceptance test steps instead of options. -->
<!-- For type done: PR link, what changed in one line, acceptance test path. -->
