#!/usr/bin/env bash
# Spec: docs/specs/os-theme.md
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_ROOT="$ROOT/nvim"
status=0

if command -v nvim >/dev/null 2>&1; then
  if nvim -l "$NVIM_ROOT/tests/theme_spec.lua"; then
    echo "PASS: nvim -l tests/theme_spec.lua"
  else
    echo "FAIL: nvim -l tests/theme_spec.lua"
    status=1
  fi
else
  echo "SKIP: nvim not on PATH; python wiring + mapping checks"
fi

if python3 "$NVIM_ROOT/tests/theme_spec.py"; then
  echo "PASS: tests/theme_spec.py"
else
  echo "FAIL: tests/theme_spec.py"
  status=1
fi

exit "$status"
