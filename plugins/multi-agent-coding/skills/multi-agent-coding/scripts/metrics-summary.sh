#!/usr/bin/env bash
# Parse docs/project-metrics.md and print a project velocity, contributor, and spend summary.

set -uo pipefail

METRICS_FILE="${1:-docs/project-metrics.md}"

if [ ! -f "$METRICS_FILE" ]; then
  echo "No metrics log found at $METRICS_FILE."
  echo "Metrics are automatically logged during /checkpoint when PRs are delivered."
  exit 0
fi

echo "============================================================"
echo "         MULTI-AGENT PROJECT METRICS & VELOCITY             "
echo "============================================================"
echo

# Filter valid markdown table rows (excluding header and comments)
ROWS=$(grep -E '^\|[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$METRICS_FILE" || true)

if [ -z "$ROWS" ]; then
  echo "No delivered features recorded in $METRICS_FILE yet."
  exit 0
fi

TOTAL_PRS=$(echo "$ROWS" | wc -l | tr -d ' ')
echo "Total Features Delivered: $TOTAL_PRS"
echo

echo "--- Breakdown by Contributor / Agent ---"
echo "$ROWS" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $5); print $5}' | sort | uniq -c | while read -r count agent; do
  printf "  • %-22s: %d feature(s)\n" "$agent" "$count"
done
echo

echo "--- Breakdown by Model ---"
echo "$ROWS" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $6); print $6}' | sort | uniq -c | while read -r count model; do
  printf "  • %-22s: %d feature(s)\n" "$model" "$count"
done
echo

echo "--- Recent Delivered Features ---"
printf "%-12s %-8s %-24s %-18s %-12s\n" "Date" "ID" "Title" "Owner" "Duration"
echo "----------------------------------------------------------------------------"
echo "$ROWS" | tail -5 | while IFS='|' read -r _ date id title owner model dur files lines tests cost _; do
  # Trim whitespace
  date=$(echo "$date" | xargs)
  id=$(echo "$id" | xargs)
  title=$(echo "$title" | cut -c1-23 | xargs)
  owner=$(echo "$owner" | xargs)
  dur=$(echo "$dur" | xargs)
  printf "%-12s %-8s %-24s %-18s %-12s\n" "$date" "$id" "$title" "$owner" "$dur"
done
echo "============================================================"
