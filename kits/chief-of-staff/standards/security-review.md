# Standard: security review

A separate review from the code review, by a separate agent. Used by Project Leads and their
`security-reviewer` subagents, on any harness.

**When:** every autonomous run (as <WORKFLOW_SKILL> says), and **every** change, even a small
fix, that touches anything on the never-auto list in `<WORKSPACE_ROOT>/_hq/decision-policy.md`:
auth, secrets, permissions, user data, payments, deletion, public content.

**Sources:** <OWNER>'s security checklist and severity in <WORKFLOW_SKILL> `references/review.md`,
the supply-chain section of `references/security.md`, and `security-and-hardening.md` in this
folder (threat model, "Security Review Checklist"). The method follows the same idea as Anthropic's
security reviews: look at the change and at the data flowing in and out of it, then confirm each
finding independently before reporting it.

## Step 1: Scope and threat model (5 minutes, written down)

- **Scope:** the changed lines, the changed files whole, and the data flowing into and out of
  them: who calls the changed code, what it now reads, writes, sends or stops checking.
- **Threat model:** what is valuable here (data, accounts, money, keys), where untrusted input
  enters, who could misuse the change, and what they would gain.

## Step 2: Find, one lens at a time

Go through each lens that applies. On a strong model, one agent can run all of them; for
High-tier items, give the lenses to separate agents.

1. Input and injection: validation at the boundary, SQL, shell, file paths, HTML, URLs fetched by the server.
2. Authentication and authorisation: every new path checks who is calling and what they may touch.
3. Data and privacy: what is stored, logged, sent to clients or third parties; deletion paths; secrets in code or history.
4. Configuration: CORS, headers, debug flags, error messages that leak internals.
5. Supply chain: each new package exists under that exact name, from the expected publisher, pinned; no script fetched and run unread.
6. AI features, if any: model output treated as untrusted; no secrets or other users' data in prompts; tool permissions scoped.

Report only flaws **the change takes part in**. A flaw whose source, sink and guards are the same
before and after the change goes to the backlog as a separate item, not into this review.

## Step 3: Verify each finding

A separate check per finding, ideally a different agent or model than the finder:
- Is the path real? Write the concrete attack or failure in one or two sentences.
- No concrete path means no finding. Note it as "considered, not confirmed" only if it is close.

## Severity

`review.md` definitions, with rule 3: nothing in this area is Low. High needs a concrete path.
Map other scales (CRITICAL, WARNING, …) onto High and Medium.

## Output (max 30 lines)

```
verdict: pass | fix-needed
threat model: <2 lines>
<High|Medium> <file:line> <risk>. Path: <how it is exploited>. Fix: <one line>.
pre-existing (backlog): <items, if any>
```

## Optional extra while Claude Code is available

On a Claude Code lead, Claude's built-in `/security-review`, or the `claude-security` plugin's
"scan changes", may run **in addition** for never-auto items. Both are Claude Code only, and
`claude-security` is proprietary, so neither can be the standard. Map their findings onto the
severities above.
