#!/usr/bin/env node
/*
 * Max's AI Coding Framework - SessionStart hook (cross-platform).
 *
 * Registered as a plugin hook in .claude-plugin/plugin.json, so it runs on every
 * session with no per-project install. Written in Node rather than bash because
 * plugin hooks run through the system shell, and a .sh command silently fails on
 * Windows.
 *
 * It prints NOTHING unless the working directory is a git repository that contains
 * project-status.md. That check is what keeps a project state block from appearing
 * in unrelated repositories.
 *
 * It only reports. It never writes, commits, or changes anything, and it never
 * touches the network - no fetch, no pull. /start does that, where the user can see
 * it happening.
 *
 * Every failure path is silent. A SessionStart hook that throws degrades every
 * session in every repository, so nothing in here is allowed to be fatal.
 */

'use strict';

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const cwd = process.env.CLAUDE_PROJECT_DIR || process.cwd();

// Caps, so a big repo or a long status file cannot flood the session context.
const MAX_STATUS_LINES = 120;
const MAX_CHANGE_LINES = 20;
const MAX_NEXT_UP_LINES = 10;

function git(args) {
  try {
    return execFileSync('git', args, {
      cwd,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      timeout: 5000,
      maxBuffer: 8 * 1024 * 1024,
    }).trim();
  } catch (err) {
    return null; // null means "could not read", distinct from '' meaning "empty"
  }
}

function readFile(p) {
  try {
    return fs.readFileSync(p, 'utf8');
  } catch (err) {
    return null;
  }
}

function exists(p) {
  try {
    return fs.existsSync(p);
  } catch (err) {
    return false;
  }
}

// Body of a `## Heading` section, up to the next `##` or the end of the string.
// Note: JavaScript has no \Z anchor - `\Z` is a literal "Z" - so end-of-string is
// `$(?![\s\S])`. Getting this wrong silently drops the last section of the file.
function section(text, heading) {
  const re = new RegExp(
    `^##[ \\t]+${heading}[ \\t]*$\\n([\\s\\S]*?)(?=^##[ \\t]|$(?![\\s\\S]))`,
    'im'
  );
  const m = text.match(re);
  return m ? m[1].trim() : null;
}

function cap(text, maxLines, what) {
  const lines = text.split('\n');
  if (lines.length <= maxLines) return text;
  return lines.slice(0, maxLines).join('\n') + `\n... (${lines.length - maxLines} more ${what})`;
}

function main() {
  if (git(['rev-parse', '--is-inside-work-tree']) !== 'true') return;

  const statusPath = path.join(cwd, 'project-status.md');
  const backlogPath = path.join(cwd, 'backlog.md');
  const statusText = exists(statusPath) ? readFile(statusPath) : null;
  const backlogText = exists(backlogPath) ? readFile(backlogPath) : null;

  // Not a framework project: say nothing. Phase 0 is reached through /kickoff, not
  // through a nag printed in every repository the user happens to open.
  if (statusText === null && backlogText === null) return;

  const out = [];
  out.push("=== PROJECT STATE (Max's AI Coding Framework) ===");
  out.push('');
  out.push(`Branch: ${git(['branch', '--show-current']) || 'unknown (detached HEAD?)'}`);

  const upstream = git(['rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}']);
  const counts = upstream
    ? git(['rev-list', '--left-right', '--count', `${upstream}...HEAD`])
    : null;
  if (upstream && counts) {
    const [behind, ahead] = counts.split(/\s+/);
    out.push(`Tracking ${upstream}: ${ahead} ahead, ${behind} behind (as of last fetch)`);
  } else if (upstream) {
    out.push(`Tracking ${upstream}: position unknown`);
  } else {
    out.push('Tracking: no upstream branch set');
  }
  out.push('');

  out.push('--- Uncommitted changes ---');
  const porcelain = git(['status', '--porcelain']);
  if (porcelain === null) {
    // Never report "(clean)" here on failure: a tree wrongly believed clean is what
    // makes /start think it is safe to pull over the user's work.
    out.push('(could not read git status - treat the tree as possibly dirty)');
  } else {
    out.push(porcelain === '' ? '(clean)' : cap(porcelain, MAX_CHANGE_LINES, 'changed files'));
  }
  out.push('');

  out.push('--- Last 10 commits ---');
  out.push(git(['log', '--oneline', '-10']) || '(no commits yet)');
  out.push('');

  if (statusText !== null) {
    out.push('--- project-status.md ---');
    out.push(cap(statusText.trim(), MAX_STATUS_LINES, 'lines - read the file for the rest'));
    out.push('');

    // Staleness check: has the repo moved on without the status file?
    const match = statusText.match(/^last updated:[ \t]*(.+)$/im);
    const statusDate = match ? Date.parse(match[1].trim()) : NaN;
    const commitEpoch = Number(git(['log', '-1', '--format=%ct']));
    const lastCommit = Number.isFinite(commitEpoch) ? commitEpoch * 1000 : 0;
    const ONE_DAY = 86400000;
    if (!Number.isNaN(statusDate) && lastCommit && lastCommit > statusDate + ONE_DAY) {
      out.push('!!! STALE STATUS !!!');
      out.push("The last commit is newer than the 'Last updated' date in project-status.md.");
      out.push('Tell the user the status file may be out of date and offer to reconstruct');
      out.push('it from git log before doing any other work.');
      out.push('');
    }
  } else {
    out.push('--- No project-status.md found ---');
    out.push('backlog.md exists but project-status.md does not. Offer to create it from');
    out.push("the template before doing any other work; it is the framework's entry point.");
    out.push('');
  }

  if (backlogText !== null) {
    // Just the Next up block. The full backlog is read on demand, not injected.
    const nextUp = section(backlogText, 'Next up');
    if (nextUp !== null) {
      out.push('--- Backlog: Next up ---');
      out.push(nextUp === '' ? '(empty)' : cap(nextUp, MAX_NEXT_UP_LINES, 'items'));
      out.push('');
    }

    // Count only inside the Items table. Counting the whole file would also match
    // rows in Known issues or Cancelled whose text happens to be a status word.
    const items = section(backlogText, 'Items') || backlogText;
    const count = (status) =>
      (items.match(new RegExp(`^\\|[^\\n]*\\|[ \\t]*${status}[ \\t]*\\|[^\\n]*$`, 'gim')) || [])
        .length;
    out.push(`Backlog: ${count('ready')} item(s) ready, ${count('implementation')} in implementation.`);
    out.push('');
  }

  out.push('Framework reminders: one PR per backlog item; nothing merges without verify +');
  out.push('subagent review + human acceptance test + status update; stop and ask after');
  out.push('three failed attempts at the same problem.');
  out.push('');
  out.push('Now do the rest of the session-start ritual: fetch from the remote, pull if the');
  out.push('branch is behind and the tree is clean, then state back to the user in two or three');
  out.push('lines where the project is and what the next step is, and ask whether to proceed.');
  out.push('=== END PROJECT STATE ===');

  process.stdout.write(out.join('\n') + '\n');
}

try {
  main();
} catch (err) {
  // Swallowed deliberately. Printing a stack trace into every session is worse than
  // printing nothing, and there is no state here worth failing a session over.
}
