#!/bin/bash
set -euo pipefail
DIR="$HOME/nyt-elections"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
TS=$(date '+%Y-%m-%d_%H-%M-%S')
cd "$DIR"
mkdir -p senate house governor electindex

# ── 1. NYT results (state-level) ──
NYT_BASE="https://static01.nyt.com/elections-assets/pages/data/2026-11-03"
curl -fsSL -o "senate/results-senate-${TS}.json"   "$NYT_BASE/results-senate.json"
curl -fsSL -o "house/results-house-${TS}.json"     "$NYT_BASE/results-house.json"
curl -fsSL -o "governor/results-governor-${TS}.json" "$NYT_BASE/results-governor.json"

# ── 2. Electindex county results ──
EX_BASE="https://tiles.electindex.com/results/2026/national"
fetch_one() {
  office="$1"
  out="electindex/counties-${office}-${TS}.json"
  code=$(curl -fsSL --compressed -A "$UA" -o "$out" -w "%{http_code}" "$EX_BASE/counties-${office}.json" 2>/dev/null) || code="000"
  if [ "$code" != "200" ]; then
    rm -f "$out"
    echo "skip ${office} ($code)"
  fi
}
export -f fetch_one
export EX_BASE UA TS
printf '%s\n' senate house governor | xargs -P 3 -I {} bash -c 'fetch_one "$@"' _ {}

# ── Commit ──
git add senate/ house/ governor/ electindex/
git commit -q -m "elections ${TS}"
git push
