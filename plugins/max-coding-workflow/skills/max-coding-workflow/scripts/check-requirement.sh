#!/usr/bin/env bash
# Check requirement files for the gaps a build agent would otherwise guess at.
# Warnings only: it never blocks, it points. The question rounds still do the real
# check (references/requirement-review.md); this catches the mechanical part cheaply.
#
#   scripts/check-requirement.sh                       every docs/requirements/*.md
#   scripts/check-requirement.sh docs/requirements/BL-014.md
#   scripts/check-requirement.sh --strict ...          exit 1 on any warning (for CI)
#
# Checks: the Run line, the template's sections, empty sections, open-choice words
# (TBD, maybe, if needed ...), leftover template placeholders, named test IDs from T01
# without gaps, and the size signals from references/planning.md.

set -uo pipefail

STRICT=0
FILES=()
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) FILES+=("$arg") ;;
  esac
done
if [ ${#FILES[@]} -eq 0 ]; then
  for f in docs/requirements/*.md; do [ -e "$f" ] && FILES+=("$f"); done
fi
if [ ${#FILES[@]} -eq 0 ]; then
  echo "No requirement files found in docs/requirements/."
  exit 0
fi

TOTAL=0
for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then echo "$file: not found"; TOTAL=$((TOTAL + 1)); continue; fi
  bytes=$(wc -c < "$file" | tr -d ' ')
  out=$(awk -v bytes="$bytes" -v file="$file" '
    function warn(msg) { print "  " msg; n++ }
    BEGIN {
      n = 0; incomment = 0; section = ""; run = ""; status = ""; rounds = ""
      split("tbd|to be decided|to be defined|decide later|maybe|probably|if needed|or similar|ask me|etc\\.|and so on|as appropriate|somehow", banned, "|")
      split("What and why|Prerequisites|Scope|Decisions already made|Data, interfaces and architecture impact|Screens and states|Behaviour and rules|Edge cases and failure cases|Acceptance criteria|Human acceptance test|Evidence|Documentation to update|Done when", full, "|")
      split("What and why|Where|Change|Acceptance criteria|Human acceptance test|Out of scope", small, "|")
    }
    {
      line = $0
      # Strip HTML comments, also across lines: template guidance is not content.
      out = ""
      while (line != "") {
        if (incomment) {
          e = index(line, "-->")
          if (e == 0) { line = ""; break }
          line = substr(line, e + 3); incomment = 0
        } else {
          s = index(line, "<!--")
          if (s == 0) { out = out line; line = ""; break }
          out = out substr(line, 1, s - 1); line = substr(line, s + 4); incomment = 1
        }
      }
      line = out

      if (FNR == 1 && match(line, /BL-[0-9]+/)) id = substr(line, RSTART, RLENGTH)
      if (line ~ /^Run:/) { run = tolower(line); sub(/^run:[ \t]*/, "", run) }
      if (line ~ /^Status:/) { status = tolower(line); sub(/^status:[ \t]*/, "", status) }
      if (line ~ /^Question rounds:/) { rounds = line; sub(/^Question rounds:[ \t]*/, "", rounds) }

      if (line ~ /^## /) {
        if (section != "" && !content[section]) empty[section] = 1
        section = line; sub(/^## +([0-9]+\. +)?/, "", section)
        seen[section] = 1; content[section] = 0
        next
      }
      if (section != "" && line ~ /[^ \t]/) content[section] = 1

      # Open-choice words, outside `code` and "quotes".
      bare = tolower(line)
      gsub(/`[^`]*`/, "", bare); gsub(/"[^"]*"/, "", bare)
      for (i in banned) {
        if (match(bare, "(^|[^a-z])" banned[i] "([^a-z]|$)"))
          { shown = banned[i]; gsub(/\\/, "", shown)
            warn("line " FNR ": open choice \"" shown "\" - decide it and write the decision down") }
      }

      # Leftover template placeholders.
      if (line ~ /BL-XXX/) warn("line " FNR ": template placeholder BL-XXX left in")
      if (line ~ /^[ \t]*(- )?\[[A-Z][^]]*\][ \t]*$/ || line ~ /^[ \t]*[0-9]+\.[ \t]*$/)
        warn("line " FNR ": unfilled template line")

      # Named tests, in their own section only.
      if (section ~ /^Acceptance criteria/) {
        rest = line
        while (match(rest, /BL-[0-9]+-T[0-9]+/)) {
          tid = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
          num = tid; sub(/.*-T/, "", num); num = num + 0
          tprefix = tid; sub(/-T[0-9]+$/, "", tprefix)
          if (id != "" && tprefix != id) warn("line " FNR ": test " tid " does not belong to " id)
          if (num in tests) warn("line " FNR ": test " tid " listed twice")
          tests[num] = 1; if (num > maxtest) maxtest = num; ntests++
        }
      }
      if (section ~ /^Human acceptance test/ && line ~ /^[ \t]*[0-9]+\./) steps++
    }
    END {
      if (section != "" && !content[section]) empty[section] = 1
      if (run == "") { warn("no \"Run:\" line - write \"Run: autonomous\" or \"Run: small fix\""); run = "autonomous" }
      if (run ~ /small/) { for (i in small) if (!(small[i] in seen)) warn("missing section: " small[i]) }
      else {
        for (i in full) {
          found = 0
          for (s in seen) if (index(s, full[i]) == 1) found = 1
          if (!found) warn("missing section: " full[i])
        }
      }
      for (s in empty) warn("empty section: " s " - write \"None.\" if nothing applies")

      if (ntests == 0) warn("no named tests (" (id != "" ? id : "BL-XXX") "-T01 ...) under Acceptance criteria")
      for (i = 1; i <= maxtest; i++) if (!(i in tests)) warn("test T" sprintf("%02d", i) " missing - number tests from T01 without gaps")

      if (run !~ /small/ && status ~ /^ready/ && (rounds == "" || rounds == "-"))
        warn("status ready, but no question rounds recorded")

      # Size signals (references/planning.md). Signals, not limits.
      if (run ~ /small/ && ntests > 3) warn("signal: " ntests " named tests for a small fix - is it an autonomous run?")
      if (bytes > 100 * 1024) warn("signal: " int(bytes / 1024) " KB, above about 100 KB - consider a split")
      if (ntests > 25) warn("signal: " ntests " named tests, above about 25 - consider a split")
      if (steps > 15) warn("signal: " steps " human acceptance steps, above about 15 - consider a split")
      exit n > 0 ? 1 : 0
    }
  ' "$file")
  status=$?
  if [ $status -ne 0 ]; then
    count=$(printf '%s\n' "$out" | grep -c .)
    echo "$file: $count warning(s)"
    printf '%s\n' "$out"
    TOTAL=$((TOTAL + count))
  else
    echo "$file: ok"
  fi
done

echo
if [ $TOTAL -eq 0 ]; then
  echo "No warnings."
else
  echo "$TOTAL warning(s). Warnings point at likely gaps; fix them or leave them on purpose."
  [ $STRICT -eq 1 ] && exit 1
fi
exit 0
