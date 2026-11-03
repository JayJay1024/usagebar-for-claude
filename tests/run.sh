#!/usr/bin/env bash
# Offline tests for the UsageBar plugin. Usage: ./tests/run.sh
set -u
cd "$(dirname "$0")/.."
PLUGIN=./plugin/usagebar.5m.sh
FIX=tests/fixtures
NOW=1793731200 # 2026-11-03T18:40:00Z
export TZ=UTC
pass=0 failed=0

run() { USAGEBAR_NOW=$NOW USAGEBAR_FIXTURE="$FIX/$1" "$PLUGIN"; }

expect() { # name, output, expected line (exact match)
  if printf '%s\n' "$2" | grep -qxF -- "$3"; then pass=$((pass + 1))
  else failed=$((failed + 1)); printf 'FAIL %s\n  expected line: %s\n  got:\n%s\n' "$1" "$3" "$2"; fi
}

out="$(run normal.json)"
expect normal-title "$out" "11% · 71% | sfimage=gauge.medium"
expect normal-session "$out" "Current session  11% used | size=13"
expect normal-bar "$out" "███████░░░ | font=Menlo size=12"
expect normal-session-reset "$out" "Resets 20:40 (in 2h 00m) | size=12 color=#8E8E93"
expect normal-week-reset "$out" "Resets Sat 07:00 (in 3d 12h) | size=12 color=#8E8E93"

out="$(run high.json)"
expect high-title-red "$out" "95% · 78% | sfimage=gauge.medium color=#FF453A"
expect high-week-orange "$out" "This week  78% used | size=13 color=#FF9F0A"
expect high-minutes "$out" "Resets 19:05 (in 25m) | size=12 color=#8E8E93"

out="$(run nulls.json)"
expect nulls-title "$out" "– · 0% | sfimage=gauge.medium"
expect nulls-empty-bar "$out" "░░░░░░░░░░ | font=Menlo size=12"
expect nulls-unknown-reset "$out" "Reset time unknown | size=12 color=#8E8E93"

out="$(run malformed.json)"
expect malformed "$out" "Unexpected response from the usage API"

out="$(USAGEBAR_KEYCHAIN_SERVICE="usagebar-test-missing-item" "$PLUGIN")"
expect missing-credentials "$out" "Claude Code credentials not found"

echo "passed: $pass, failed: $failed"
[ "$failed" -eq 0 ]
