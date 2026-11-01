# Agent rules for [project]

This project follows the max-coding-workflow process. Start every session by reading
`docs/handover.md` (if it exists), `project-status.md` and `backlog.md`.

Where things live: requirements in `docs/requirements/`, decisions in
`architecture.md`, run rules in `docs/run-protocol.md`, lessons per phase in
`learnings.md` (read the section for your phase before planning or a run).

## Always relevant
<!-- Only traps that can hit in any turn, whatever the phase. About five lines at most:
this file is loaded in every session. Everything else goes to learnings.md. -->
- Before installing a package or tool, or running a script from outside the repo,
  verify its name, publisher, source and checksum; never pipe a download into a shell.
- Anything security-relevant that looks wrong: contain it, tell the user at once, log
  it under "Security incidents" in `project-status.md`, add the rule here.
- [e.g. The app uses Next.js 16: `proxy.ts` instead of middleware. Check
  `node_modules/next/dist/docs/` before using an API you are unsure about.]
