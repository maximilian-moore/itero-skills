# Phase 3: Architecture

`architecture.md` answers two different questions, and both matter.

**What is this built from** - the current state. Stack, structure, data model,
auth, hosting, cost. A new session reads this to orient itself.

**Why is it built that way** - the ADR log. Decisions, alternatives considered, and
the reasoning. This is the part a fresh context window cannot reconstruct, and it is
the reason this file exists at all rather than just reading the code.

---

## How to propose architecture

Never decide silently. The user is a capable builder who can and should overrule you,
but only if you show your reasoning.

For each significant choice, present it like this:

> **Data storage.** I would recommend SQLite via a local file for now.
> Alternatives: Postgres on Supabase, or plain JSON files.
> Why SQLite: you said this is single-user on your laptop, and it needs zero setup and
> zero monthly cost. It gives you real queries, which JSON files do not.
> The tradeoff: if you later want this accessible from your phone, you will need to
> move to a hosted database. That migration is real work, maybe half a day.
> Say the word if you would rather pay that cost now instead of later.

Recommendation, alternatives, reason, tradeoff, exit. Every time. If the user does not
have an opinion, your recommendation stands and gets logged as an ADR.

## What the four kickoff answers determine

Map them directly, and say out loud that you are doing it:

- **Where it runs** determines language, framework, and deployment target
- **Who can access it** determines auth model and whether you need a backend at all
- **Where data lives** determines database, backup strategy, and hosting region
- **What it costs** constrains every one of the above

If the user's answers conflict with each other, surface it now. "You want this
accessible from your phone but stored only on your laptop" is a contradiction that is
much cheaper to resolve in conversation than in code.

## Bias toward boring

For a non-developer builder, the right default is nearly always the most common,
best-documented option, not the most elegant one. When something breaks at 11pm, you
want an error message that a thousand other people have already hit and answered.
Novel tools mean novel problems, and novel problems mean you are on your own.

Say this out loud when recommending. It is a real reason, not a hedge.

## The ADR log

Append to `architecture.md`. Never rewrite an old entry, even a wrong one. Supersede
it with a new entry instead, because the wrong decision and the reason it was wrong
are exactly what stop you making it again.

```markdown
### ADR-003: Use SQLite instead of a hosted database
Date: 2026-08-30
Status: accepted

**Context.** Single user, runs locally, no monthly budget.
**Decision.** SQLite file at ./data/app.db.
**Alternatives.** Supabase Postgres (free tier, but adds a network dependency and an
account), JSON files (no queries, painful past a few hundred records).
**Consequences.** Zero setup and zero cost. Multi-device access later means a
migration, roughly half a day of work.
```

Four ADR statuses: `proposed`, `accepted`, `superseded by ADR-XXX`, `rejected`.

## The architecture impact check

This is the mechanism that stops `architecture.md` becoming fiction.

Every implementation plan in Phase 5 has an **Architecture impact** section. If an item
changes a decision recorded here, `architecture.md` is updated **in the same PR** as
the code, with a new ADR explaining what changed and why.

Not in a follow-up. Not in a cleanup task later. The same PR, or the file starts lying
and every future session inherits the lie.

## When the architecture turns out wrong

It will, at least once. That is not a failure of the process, it is the process
working. You found out cheaply.

When it happens: stop, write an ADR that supersedes the old decision, add a backlog
item for the migration, and estimate it honestly for the user. Do not quietly work
around a broken decision in feature code. Workarounds compound, and six months later
nobody remembers which parts are the workaround and which parts are the design.
