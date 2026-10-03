---
description: Start a new multi-agent project - Phases 0 to 4 (repo, interview, backlog, architecture, UX)
---

Read `references/kickoff.md`.

Run Phases 0 through 4 in sequence for a new project:

1. **Phase 0: Repository & Secrets Setup**
   - Initialize git repo (private by default).
   - Create `.gitignore` from `assets/templates/gitignore.txt`.
   - Create `.env.example` and `docs/SETUP.md`.
   - Create `scripts/verify.sh` and make executable (`chmod +x scripts/verify.sh`).

2. **Phase 1: Kickoff Interview**
   - Conduct the structured interview (Blocks A through E).
   - Establish milestones (M1: MVP Core, M2, M3).
   - Identify contributing agents and establish actor IDs.

3. **Phase 2: Initialize the Backlog & Playbook**
   - Create `backlog.md` using `assets/templates/backlog.md` with initial milestones.
   - Create `docs/delivered.md` from `assets/templates/delivered.md`.
   - Create `docs/cancelled.md` from `assets/templates/cancelled.md`.
   - Create `docs/learnings.md` from `assets/templates/learnings.md`.
   - Create `docs/project-metrics.md` from `assets/templates/project-metrics.md`.

4. **Phase 3: Architecture & System Boundaries**
   - Create `architecture.md` from `assets/templates/architecture.md`.
   - Document stack, boundaries, concurrency rules, and first ADR entries.

5. **Phase 4: User Journey & Design Tokens**
   - Create `docs/user-journey.md` from `assets/templates/user-journey.md`.

6. **Create initial project status:**
   - Create `project-status.md` from `assets/templates/project-status.md`.
   - Commit everything as the initial project baseline checkpoint.
