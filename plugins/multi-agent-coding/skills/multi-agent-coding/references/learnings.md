# Continuous Learning & The Repository Playbook

When an AI agent spends thirty minutes debugging an obscure build error, discovering
a 5x faster testing command, or working around a quirky ORM behavior, that knowledge
normally vanishes the moment the conversation window closes.

The next agent starts completely fresh, hits the exact same wall, and burns another
thirty minutes.

**Continuous Learning** solves this by establishing a durable **Repository Playbook**
at `docs/learnings.md`.

---

## 1. Structure of `docs/learnings.md`

The playbook is a curated markdown document organized into four practical categories,
each bullet prefixed with a domain tag for instant scannability:

```markdown
# Repository Playbook & Learnings

Operational wisdom, speedups, and traps discovered by contributors and AI agents.

## 1. Speedups & Dev Tooling
- `[Testing]` Run fast unit tests with `npm test -- --filter=unit` (3s vs 45s for full suite).
- `[Database]` Seed local development data in 2 seconds with `npm run db:fast-seed`.
- `[Build]` Pass `--no-emit` when checking types to avoid polluting `dist/`.

## 2. Framework & System Traps
- `[Auth]` Token expiry must be verified in edge middleware before hitting the session database.
- `[Prisma]` Transactions crash in Docker if the connection pool exceeds 10. Keep `connection_limit=5`.
- `[NextJS]` Server Actions cannot return complex class instances; serialize to plain JSON objects.

## 3. Testing Tricks & Mocking
- `[Stripe]` Use the mock helper in `tests/mocks/stripe.ts` instead of constructing raw webhook payloads.
- `[Time]` All unit tests asserting dates must run with `TZ=UTC` or three localized tests fail.

## 4. Patterns & Code Conventions
- `[API]` All endpoint responses must conform to `ApiResponse<T>` in `src/types/api.ts`.
- `[Logging]` Never log raw user email or tokens; always pass through `sanitizeLog()` in `src/lib/logger.ts`.
```

---

## 2. The Checkpoint Harvesting Protocol

Learnings are not added spontaneously; they are collected systematically during the
`/checkpoint` ritual before any PR is merged.

The Orchestrator asks the Worker Subagent and evaluates the diff against four questions:
1. **Did anything fail repeatedly or take more than 10 minutes to resolve?**
   If yes, what was the root cause and what is the fix?
2. **Did you discover a faster way to build, run, or test in this repo?**
   If yes, what is the exact command or shortcut?
3. **Is there a non-obvious requirement or edge case in this domain?**
   If yes, what should future agents watch out for?
4. **Did you introduce a new shared helper or pattern?**
   If yes, where does it live and when should others use it?

If any answer yields actionable knowledge, append a concise bullet to `docs/learnings.md`
under the appropriate section with a domain tag.

---

## 3. Ingestion at Session Start (`/start`)

When `/start` runs:
1. The Orchestrator reads `docs/learnings.md` (focusing on Traps and Speedups).
2. When creating the Worker Subagent brief for `/implement`, the Orchestrator extracts
   any entries matching the tags relevant to the current feature (e.g. `[Auth]`, `[Database]`).
3. The Worker Subagent immediately operates with the collective experience of every
   previous session.

---

## 4. Playbook Hygiene & Pruning

Like code, learnings must be maintained to stay effective:
- **Keep bullets concise:** One or two sentences. Link to code examples if necessary.
- **Prune when obsolete:** When a library upgrade resolves a known bug or a script is
  replaced, delete or update the corresponding bullet.
- **Do not duplicate `architecture.md`:** Architecture files record *structural decisions*
  (ADRs: why we chose PostgreSQL over MongoDB). `docs/learnings.md` records *operational
  realities* (how to query PostgreSQL without hitting connection limits).
