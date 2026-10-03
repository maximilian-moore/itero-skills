#!/usr/bin/env node
/*
 * Multi-Agent Coding Framework - SessionStart hook (cross-platform).
 *
 * Registered as a plugin hook in .claude-plugin/plugin.json.
 * Only reports. Never writes, commits, or touches the network.
 * Silent in non-framework repositories.
 */

'use strict';

const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const cwd = process.env.CLAUDE_PROJECT_DIR || process.cwd();

const MAX_STATUS_LINES = 120;
const MAX_CHANGE_LINES = 20;
const MAX_NEXT_UP_LINES = 10;
const MAX_LEARNING_LINES = 15;

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
    return null;
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
  const learningsPath = path.join(cwd, 'docs', 'learnings.md');

  const statusText = exists(statusPath) ? readFile(statusPath) : null;
  const backlogText = exists(backlogPath) ? readFile(backlogPath) : null;
  const learningsText = exists(learningsPath) ? readFile(learningsPath) : null;

  if (statusText === null && backlogText === null) return;

  const out = [];
  out.push('=== PROJECT STATE (Multi-Agent Coding Framework) ===');
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
    out.push(cap(statusText.trim(), MAX_STATUS_LINES, 'lines'));
    out.push('');

    // Staleness check
    const match = statusText.match(/^last updated:[ \t]*(.+)$/im);
    const statusDate = match ? Date.parse(match[1].trim()) : NaN;
    const commitEpoch = Number(git(['log', '-1', '--format=%ct']));
    const lastCommit = Number.isFinite(commitEpoch) ? commitEpoch * 1000 : 0;
    const ONE_DAY = 86400000;
    if (!Number.isNaN(statusDate) && lastCommit && lastCommit > statusDate + ONE_DAY) {
      out.push('!!! STALE STATUS WARNING !!!');
      out.push("The newest commit is newer than the 'Last updated' date in project-status.md.");
      out.push('');
    }
  }

  if (backlogText !== null) {
    const inFlight = section(backlogText, 'In Flight');
    if (inFlight !== null && inFlight.trim() !== '') {
      out.push('--- Active In-Flight Tasks (Claimed) ---');
      out.push(inFlight);
      out.push('');
    }

    const nextUp = section(backlogText, 'Next Up');
    if (nextUp !== null) {
      out.push('--- Next Up Queue ---');
      out.push(nextUp === '' ? '(empty)' : cap(nextUp, MAX_NEXT_UP_LINES, 'items'));
      out.push('');
    }
  }

  if (learningsText !== null) {
    out.push('--- Recent Repo Learnings & Traps ---');
    out.push(cap(learningsText.trim(), MAX_LEARNING_LINES, 'lines - read docs/learnings.md for more'));
    out.push('');
  }

  out.push('Multi-Agent rules: Claim before code (remote branch lock); one PR per item;');
  out.push('Orchestrator delegates build to worker subagent; pre-merge rebase + verify;');
  out.push('Harvest learnings and log metrics at checkpoint.');
  out.push('');
  out.push('Now do session-start: fetch remote, check in-flight locks, report state to user, and ask.');
  out.push('=== END PROJECT STATE ===');

  process.stdout.write(out.join('\n') + '\n');
}

try {
  main();
} catch (err) {
  // Silent on error
}
