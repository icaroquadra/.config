#!/usr/bin/env bash
# AC 2–5: appearance/apply.sh day|night|auto and missing gsettings.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY="$ROOT/appearance/apply.sh"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "PASS: $*"; }

run_with_mock() {
  local mockdir
  mockdir="$(mktemp -d)"
  cat >"$mockdir/gsettings" <<'EOF'
#!/usr/bin/env bash
echo "$@" >>"${GSETTINGS_LOG:?}"
EOF
  for cmd in kitty tmux fish; do
    cat >"$mockdir/$cmd" <<'EOF'
#!/usr/bin/env bash
echo "$(basename "$0") $*" >>"${GSETTINGS_LOG:?}"
exit 0
EOF
  done
  chmod +x "$mockdir"/*
  GSETTINGS_LOG="$mockdir/gsettings.log" PATH="$mockdir:$PATH" \
    APPEARANCE_CONF="$ROOT/appearance/schedule.conf" \
    APPEARANCE_STATE="$mockdir/state" \
    "$@"
  echo "$mockdir"
}

assert_log_has() {
  local log="$1" needle="$2"
  if grep -Fqx "$needle" "$log"; then
    pass "log has: $needle"
  else
    fail "log missing: $needle (got: $(tr '\n' ' ' <"$log"))"
  fi
}

assert_file_has() {
  local file="$1" needle="$2"
  if grep -Fq "$needle" "$file"; then
    pass "$file has: $needle"
  else
    fail "$file missing: $needle"
  fi
}

# AC2 day
dir="$(run_with_mock bash "$APPLY" day)"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface color-scheme prefer-light"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface gtk-theme Adwaita"
assert_file_has "$dir/state/kitty.conf" "background #eff1f5"
assert_file_has "$dir/state/tmux.conf" "bg=#eff1f5"
assert_log_has "$dir/gsettings.log" "fish $ROOT/fish/themes/day.fish"

# AC3 night
dir="$(run_with_mock bash "$APPLY" night)"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface color-scheme prefer-dark"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface gtk-theme Adwaita-dark"
assert_file_has "$dir/state/kitty.conf" "background #1e1e2e"
assert_file_has "$dir/state/tmux.conf" "bg=#1e1e2e"
assert_log_has "$dir/gsettings.log" "fish $ROOT/fish/themes/night.fish"

# AC4 auto boundaries
dir="$(run_with_mock env APPEARANCE_NOW=07:00 bash "$APPLY" auto)"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface color-scheme prefer-light"

dir="$(run_with_mock env APPEARANCE_NOW=18:00 bash "$APPLY" auto)"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface color-scheme prefer-dark"

dir="$(run_with_mock env APPEARANCE_NOW=06:59 bash "$APPLY" auto)"
assert_log_has "$dir/gsettings.log" "set org.gnome.desktop.interface color-scheme prefer-dark"

# AC5 missing gsettings (PATH has bash/env only)
nodir="$(mktemp -d)"
ln -s "$(command -v bash)" "$nodir/bash"
ln -s "$(command -v env)" "$nodir/env"
ln -s "$(command -v mkdir)" "$nodir/mkdir"
ln -s "$(command -v cp)" "$nodir/cp"
ln -s "$(command -v date)" "$nodir/date"
ln -s "$(command -v dirname)" "$nodir/dirname"
ln -s "$(command -v true)" "$nodir/true"
if PATH="$nodir" APPEARANCE_CONF="$ROOT/appearance/schedule.conf" \
  APPEARANCE_STATE="$nodir/state" bash "$APPLY" day; then
  pass "missing gsettings exits 0"
else
  fail "missing gsettings must exit 0 (got $?)"
fi

# AC6 redshift.conf values (file in repo; no redshift binary needed)
conf="$ROOT/redshift/redshift.conf"
for pair in 'temp-day=6500' 'temp-night=3500' 'dawn-time=7:00' 'dusk-time=18:00'; do
  if grep -Fq "$pair" "$conf"; then
    pass "redshift.conf has $pair"
  else
    fail "redshift.conf missing $pair"
  fi
done

exit "$FAIL"
