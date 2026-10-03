# Phase 3: Architecture & System Boundaries

`architecture.md` answers two critical questions in a collaborative codebase:
1. **What is this built from** - Stack, directory structure, data schema, system boundaries.
2. **Why is it built that way** - The Architecture Decision Record (ADR) log.

In multi-agent systems, agents cannot guess why an unusual library or database setup
was chosen. The ADR log is the single defense against agents refactoring working code
back into broken designs.

---

## 1. Structure of `architecture.md`

```markdown
# Architecture

## Stack
- Framework: Next.js (App Router)
- Language: TypeScript (strict mode)
- Database: PostgreSQL via Prisma ORM
- Styling: Tailwind CSS
- Testing: Vitest (unit), Playwright (e2e)

## System Boundaries & Directory Map
- `src/app/`: UI routes and API endpoints
- `src/services/`: Core domain logic (framework-agnostic)
- `src/lib/`: Database clients, logging, third-party integrations
- `docs/`: Project documentation, requirements, plans, learnings, metrics

## Concurrency & State Rules
- Shared database access: Use transaction wrappers in `src/lib/db.ts`
- Migrations: Sequential numbered files in `prisma/migrations/`
- Test isolation: Unit tests must use mock repositories; e2e tests run on port 3001

## Decision Log (ADRs)

### ADR-001: Next.js App Router for unified UI and API
Date: 2026-10-01
Status: accepted
Context: Need quick full-stack deployment on Vercel with server-side secrets.
Decision: Next.js 15 App Router.
Alternatives: Vite SPA + FastAPI (higher operational overhead).
Consequences: Server actions require careful parameter validation.
```

---

## 2. ADR Rules

- Append new ADRs at the bottom of the log.
- Never overwrite or delete an old ADR. If a decision changes, mark the status of the
  old ADR as `superseded by ADR-XXX` and add the new ADR explaining why.
- **Architecture Impact Check:** If an implementation plan has `Architecture Impact: Yes`,
  the new ADR must be committed in the exact same PR as the code changes.
