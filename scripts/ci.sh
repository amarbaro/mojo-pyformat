#!/usr/bin/env bash
# CI entry point, same on a GitHub runner and a local VM: install, build, then every check.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v uv >/dev/null || { echo "FAIL setup: uv not installed"; exit 1; }
uv sync || { echo "FAIL setup: uv sync"; exit 1; }
python3 -c 'import sys; print("oracle python", sys.version.split()[0])'
M=.venv/bin/mojo
mkdir -p .work
$M build -I src tests/cases.mojo -o .work/cases || { echo "FAIL build: tests/cases.mojo"; exit 1; }
CASES=.work/cases scripts/check.sh
python3 -I tools/oracle_wide.py > .work/wide.txt
.work/cases .work/wide.txt > .work/wide.got || { echo "FAIL run: wide cases"; exit 1; }
diff .work/wide.txt .work/wide.got > .work/wide.diff || { echo "FAIL wide: $(grep -c '^<' .work/wide.diff) line(s) differ from Python"; head -10 .work/wide.diff; exit 1; }
echo "wide: $(wc -l < .work/wide.txt) cases identical"
$M run -I src tests/api.mojo || { echo "FAIL api: tests/api.mojo"; exit 1; }
$M run -I src examples/quickstart.mojo > /dev/null || { echo "FAIL example: examples/quickstart.mojo"; exit 1; }
echo "PASS all"
