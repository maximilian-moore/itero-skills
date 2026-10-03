# Phase 1: The Multi-Agent Kickoff Interview

The goal is not just a feature list. The goal is enough understanding to choose an
architecture and milestone structure that will support multiple contributors and agents
without structural collisions.

Interview properly. Ask questions in small batches (two or three at a time), react to the
answers, and do not let fuzzy answers stand.

---

## Block A - What and Why
1. Describe what this does in one sentence, as if to a colleague who does not code.
2. Who uses it? Just you, your team, or public end users?
3. What do they do today instead? What is broken about that?
4. What does "this worked" look like in three months? Be concrete.
5. What is explicitly *not* in scope for v1? Name at least two non-goals.

---

## Block B - The Four Retrofit-Expensive Decisions
These four are cheap now and brutally expensive later:
1. **Where does it run?** (Local CLI, web app, mobile app, background worker, Docker?)
2. **Who can access it?** (Single user, team SSO, public accounts, API keys?)
3. **Where does data live?** (In memory, SQLite, hosted Postgres, external SaaS?)
4. **What does it cost to run?** (Hosting, database, API token budget per month?)

---

## Block C - Data, Privacy & Compliance
- Does this store or process personal data (PII), customer data, or secrets?
- If yes, what are the retention and deletion requirements?

---

## Block D - Milestones & Epics
Structure the project into 2 to 4 sequential milestones:
- **M1: Core MVP** - Minimum functional slice end-to-end.
- **M2: Production Hardening** - Auth, persistence, error resilience, logging.
- **M3: Growth / Secondary Features** - Exporting, sharing, optimizations.

Each backlog item created in Phase 2 will attach to one of these milestones.

---

## Block E - Collaboration & Contributor Setup
- **Contributors:** Who or which AI agents will contribute (e.g. human dev, Claude, Gemini)?
- **Concurrency Mode:** Will agents work sequentially (one at a time) or in parallel
  using Git worktrees on separate branches?
- Establish the actor ID format (e.g. `user-max`, `agent-claude`, `agent-antigravity`).
