#!/bin/bash
set -euo pipefail

DIR="$HOME/nyt-elections"
BASE="https://static01.nyt.com/elections-assets/pages/data/2026-11-03"
TS=$(date '+%Y-%m-%d_%H-%M-%S')

cd "$DIR"

curl -fsSL -o "results-senate-${TS}.json"   "$BASE/results-senate.json"
curl -fsSL -o "results-house-${TS}.json"    "$BASE/results-house.json"
curl -fsSL -o "results-governor-${TS}.json" "$BASE/results-governor.json"

git add results-senate-*.json results-house-*.json results-governor-*.json
git commit -q -m "elections ${TS}"
git push
