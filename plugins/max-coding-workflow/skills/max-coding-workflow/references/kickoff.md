# Phase 1: The kickoff interview

The goal is not a feature list. The goal is enough understanding to choose an
architecture that will not have to be thrown away in three weeks.

Interview properly. Push back on vague answers. A user who says "it should be simple"
usually means "I haven't thought about it yet", and agreeing with them now costs a
rewrite later. Be respectful but do not let a fuzzy answer stand.

**How to run it:** ask in small groups, two or three questions at a time, and react to
the answers. A wall of twenty questions gets skimmed and answered badly. Follow the
threads that sound uncertain.

---

## Block A - What and why

1. Describe what this does in one sentence, as if to a friend who does not code.
2. Who uses it? Just you, a handful of people, or strangers on the internet?
3. What do they do today instead? What is annoying about that?
4. What does "this worked" look like in three months? Be concrete.
5. What is explicitly *not* in scope? Name at least two things.

Question 5 matters more than it looks. A stated non-goal is the cheapest scope
protection available, and it is the thing you point back to in Phase 5 when the build
starts sprawling.

## Block B - The four retrofit-expensive decisions

These four are cheap now and brutally expensive later. Get real answers. If the user
does not know, work it out together rather than deferring.

**1. Where does it run?**
Local script on your laptop, a web app on a host, a mobile app, a scheduled job, a
CLI tool? This decides most of the stack. "I'll figure out hosting later" is how
prototypes die.

**2. Who can access it?**
Nobody but you, a shared password, real accounts with logins, or fully public? Adding
authentication to something built without it is close to a rewrite of every data path.

**3. Where does data live?**
In memory, a local file, SQLite, a hosted database, someone else's API? And what
happens if it is lost? If the answer is "that would be bad", you need backups from the
start, not later.

**4. What does it cost to run?**
Per month at zero users, and per month at the realistic number of users. LLM API
calls, hosting, database, storage. A tool that costs a few cents per user is a
different product from one that costs a few euros per user. Work out a rough number
now, and write it into `architecture.md`.

## Block C - Data and legal

Ask directly, and do not treat it as a formality if the answer is yes.

- Does this touch personal data? Names, emails, photos, messages, location, anything
  that identifies a person.
- If yes: whose data, stored where, for how long, and can it be deleted on request?
  Under GDPR this is not optional, and it constrains hosting region and storage design.
- Does it touch employer systems, internal data, or proprietary processes? If yes,
  this stays private and separate from personal projects. Flag it now, loudly.
- Are there credentials to third-party services, and what is the worst thing someone
  could do with them if they leaked?

## Block D - Constraints and taste

1. How much time do you realistically have? A weekend, or ongoing evenings?
2. Any stack you already know, or specifically want to learn on this project?
3. Anything that must integrate with something you already run?
4. How much does the interface matter? Is this a tool you tolerate, or something you
   want to show people?

Question 4 routes Phase 4. If the interface matters, push toward a design tool. If it
does not, say so plainly and save the user the effort.

## Block E - The future

1. What is the obvious next feature after v1, the one you already know you will want?
2. What would need to change if this got ten times more use than expected?
3. What part are you least sure about?

The answers here go into `architecture.md` as forces on the design, not as features to
build. You are looking for the things that must not be painted into a corner.

---

## What to produce

Write nothing to disk until the user confirms your summary is right.

1. **Play it back.** A short summary: the one-sentence description, the users, the
   four retrofit answers, the non-goals. Ask what you got wrong. Expect corrections.
2. **A raw feature list.** Everything mentioned, unfiltered, unprioritised. This
   becomes the backlog in Phase 2.
3. **Open questions.** Anything the user could not answer. These go into
   `project-status.md` under Open decisions, so they are not quietly forgotten.

Then move to Phase 2 and read `references/backlog.md`.

**Resist building.** The most common failure of an AI-assisted kickoff is starting to
code during the interview because a feature sounded easy. Do not. The code written
before the architecture exists is the code you throw away.
