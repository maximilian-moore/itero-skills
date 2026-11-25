#!/usr/bin/env python3
"""Token usage per project, from local Claude Code and Codex logs.

T3's Usage view breaks usage down by provider and model, not by project.
This script reads the same local logs and groups them by the working
directory each session ran in.

Usage:  python3 -I usage-by-project.py [--days 7] [--since YYYY-MM-DD]

Covered: Claude Code (also Claude threads started by T3) and Codex.
Not covered: Antigravity. It stores usage in binary protobuf; use T3's
Usage view for its total.
"""
import argparse
import collections
import datetime as dt
import json
import pathlib

HOME = pathlib.Path.home()
DEV = HOME / "Documents" / "DevProjects"
T3_WORKTREES = HOME / ".t3" / "worktrees"
PROJECTS = {p.name for p in DEV.iterdir() if p.is_dir()} if DEV.exists() else set()


def project_of(cwd):
    if not cwd:
        return "(unknown)"
    path = pathlib.Path(cwd)
    for root in (DEV, T3_WORKTREES):
        try:
            rel = path.relative_to(root)
        except ValueError:
            continue
        if root == DEV:
            return rel.parts[0] if rel.parts else "DevProjects (root)"
        # A worktree path contains the project name somewhere.
        for part in rel.parts:
            if part in PROJECTS:
                return part
        return "(worktree)"
    return "(outside DevProjects)"


def parse_ts(value):
    try:
        return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (AttributeError, ValueError):
        return None


def new_row():
    return collections.Counter()


def scan_claude(since, totals):
    seen = set()
    for f in (HOME / ".claude" / "projects").rglob("*.jsonl"):
        try:
            lines = f.open(encoding="utf-8", errors="replace")
        except OSError:
            continue
        with lines:
            for line in lines:
                if '"usage"' not in line:
                    continue
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                msg = d.get("message") or {}
                usage = msg.get("usage")
                if d.get("type") != "assistant" or not usage:
                    continue
                key = (msg.get("id"), d.get("requestId"))
                if key in seen:  # streamed messages repeat the same usage
                    continue
                seen.add(key)
                ts = parse_ts(d.get("timestamp"))
                if since and (ts is None or ts < since):
                    continue
                row = totals[(project_of(d.get("cwd")), "claude")]
                row["input"] += usage.get("input_tokens", 0) or 0
                row["cache_write"] += usage.get("cache_creation_input_tokens", 0) or 0
                row["cache_read"] += usage.get("cache_read_input_tokens", 0) or 0
                row["output"] += usage.get("output_tokens", 0) or 0
                row["turns"] += 1


def scan_codex(since, totals):
    for f in (HOME / ".codex" / "sessions").rglob("*.jsonl"):
        cwd = None
        try:
            lines = f.open(encoding="utf-8", errors="replace")
        except OSError:
            continue
        with lines:
            for line in lines:
                if cwd is None and '"session_meta"' in line:
                    try:
                        cwd = json.loads(line)["payload"].get("cwd")
                    except (json.JSONDecodeError, KeyError, TypeError):
                        pass
                    continue
                if '"token_count"' not in line:
                    continue
                try:
                    d = json.loads(line)
                    last = d["payload"]["info"]["last_token_usage"]
                except (json.JSONDecodeError, KeyError, TypeError):
                    continue
                ts = parse_ts(d.get("timestamp"))
                if since and (ts is None or ts < since):
                    continue
                cached = last.get("cached_input_tokens", 0) or 0
                row = totals[(project_of(cwd), "codex")]
                row["input"] += max((last.get("input_tokens", 0) or 0) - cached, 0)
                row["cache_read"] += cached
                row["cache_write"] += last.get("cache_write_input_tokens", 0) or 0
                row["output"] += (last.get("output_tokens", 0) or 0)
                row["turns"] += 1


def fmt(n):
    return f"{n / 1e6:.2f}M" if n >= 1e6 else f"{n / 1e3:.0f}k"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--days", type=int, default=7)
    ap.add_argument("--since", help="YYYY-MM-DD; overrides --days")
    args = ap.parse_args()
    if args.since:
        since = dt.datetime.fromisoformat(args.since).replace(tzinfo=dt.timezone.utc)
    else:
        since = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=args.days)

    totals = collections.defaultdict(new_row)
    scan_claude(since, totals)
    scan_codex(since, totals)

    rows = sorted(totals.items(), key=lambda kv: -(kv[1]["input"] + kv[1]["cache_write"] + kv[1]["output"]))
    print(f"Token usage since {since.date()} (Claude Code + Codex local logs)\n")
    print("| Project | Tool | Turns | New input | Cache write | Cache read | Output |")
    print("|---|---|---:|---:|---:|---:|---:|")
    for (project, tool), r in rows:
        print(f"| {project} | {tool} | {r['turns']} | {fmt(r['input'])} | {fmt(r['cache_write'])} "
              f"| {fmt(r['cache_read'])} | {fmt(r['output'])} |")
    print("\nCache reads cost about a tenth of new input; output is the most expensive column.")


if __name__ == "__main__":
    main()
