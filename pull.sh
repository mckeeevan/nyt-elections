#!/bin/bash
# Scrape the 2026 election results into the mirror repo. Run via cron every
# 3 minutes. Two sources, both saved raw:
#   1. NYT results (state-level)  -> results-{senate,house,governor}.json
#   2. Electindex county results  -> electindex/counties-{senate,house,governor}.json
set -euo pipefail
DIR="$HOME/nyt-elections"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
cd "$DIR"
mkdir -p electindex
# ── 1. NYT results (state-level) ──
NYT_BASE="https://static01.nyt.com/elections-assets/pages/data/2026-11-03"
curl -fsSL -o results-senate.json   "$NYT_BASE/results-senate.json"
curl -fsSL -o results-house.json    "$NYT_BASE/results-house.json"
curl -fsSL -o results-governor.json "$NYT_BASE/results-governor.json"
# ── 2. Electindex county results (real per-county votes) ──
EX_BASE="https://tiles.electindex.com/results/2026/national"
fetch_one() {
  office="$1"
  out="electindex/counties-${office}.json"
  code=$(curl -fsSL --compressed -A "$UA" -o "$out" -w "%{http_code}" "$EX_BASE/counties-${office}.json" 2>/dev/null) || code="000"
  if [ "$code" != "200" ]; then
    rm -f "$out"
    echo "skip ${office} ($code)"
  fi
}
export -f fetch_one
export EX_BASE UA
printf '%s\n' senate house governor | xargs -P 3 -I {} bash -c 'fetch_one "$@"' _ {}
# ── Commit both sources together ──
git add results-senate.json results-house.json results-governor.json electindex/
if git diff --cached --quiet; then
  exit 0
fi
git commit -q -m "elections update $(date '+%Y-%m-%d %H:%M:%S')"
git push
