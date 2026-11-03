#!/bin/bash
set -euo pipefail

DIR="$HOME/nyt-elections"
BASE="https://static01.nyt.com/elections-assets/pages/data/2026-11-03"

cd "$DIR"

curl -fsSL -o results-senate.json   "$BASE/results-senate.json"
curl -fsSL -o results-house.json    "$BASE/results-house.json"
curl -fsSL -o results-governor.json "$BASE/results-governor.json"

git add results-senate.json results-house.json results-governor.json

if git diff --cached --quiet; then
  exit 0
fi

git commit -q -m "elections update $(date '+%Y-%m-%d %H:%M:%S')"
git push
