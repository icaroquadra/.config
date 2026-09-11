#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0
for t in "$ROOT"/apply-appearance.sh "$ROOT"/install-links.sh "$ROOT"/bootstrap-debian.sh; do
  echo "== $(basename "$t")"
  if bash "$t"; then
    echo
  else
    status=1
    echo
  fi
done
exit "$status"
