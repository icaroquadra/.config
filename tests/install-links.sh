#!/usr/bin/env bash
# AC1 + AC7: install.sh links layout table; systemd skipped in this env.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { echo "FAIL: $*" >&2; FAIL=1; }
pass() { echo "PASS: $*"; }

home="$(mktemp -d)"
export HOME="$home"
export XDG_CONFIG_HOME="$home/.config"
export DOTFILES_SKIP_SYSTEMD=1
export DOTFILES_SKIP_TPM=1

bash "$ROOT/install.sh" >/dev/null

expect_link() {
  local dest="$1" src="$2"
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
    pass "$dest -> $src"
  else
    fail "$dest expected link to $src (got: $(readlink "$dest" 2>/dev/null || echo missing))"
  fi
}

cfg="$XDG_CONFIG_HOME"
if [[ -f "$cfg/redshift.conf" ]] && ! [[ -L "$cfg/redshift.conf" ]] \
  && cmp -s "$cfg/redshift.conf" "$ROOT/redshift/redshift.conf"; then
  pass "$cfg/redshift.conf copied from repo"
else
  fail "$cfg/redshift.conf must be a regular copy of repo redshift.conf"
fi
if [[ -L "$cfg/redshift" ]]; then
  fail "legacy $cfg/redshift symlink must be removed (AppArmor)"
else
  pass "no $cfg/redshift dir symlink"
fi
expect_link "$cfg/appearance" "$ROOT/appearance"
expect_link "$cfg/tmux" "$ROOT/tmux"
expect_link "$home/.tmux.conf" "$ROOT/tmux/tmux.conf"
expect_link "$cfg/autostart/redshift.desktop" "$ROOT/autostart/redshift.desktop"
expect_link "$cfg/autostart/appearance.desktop" "$ROOT/autostart/appearance.desktop"
expect_link "$cfg/systemd/user/appearance.service" "$ROOT/systemd/user/appearance.service"
expect_link "$cfg/systemd/user/appearance.timer" "$ROOT/systemd/user/appearance.timer"

if [[ -e "$cfg/autostart/redshift-gtk.desktop" ]]; then
  fail "legacy autostart/redshift-gtk.desktop must be removed"
else
  pass "no redshift-gtk.desktop leftover"
fi

if grep -Fq 'TryExec=redshift' "$ROOT/autostart/redshift.desktop" \
  && grep -Eq '^Exec=redshift$' "$ROOT/autostart/redshift.desktop" \
  && ! grep -Fq 'redshift-gtk' "$ROOT/autostart/redshift.desktop"; then
  pass "autostart uses headless redshift"
else
  fail "autostart must Exec=redshift (default ~/.config/redshift.conf), not gtk/-c"
fi

# AC8: xrandr then dex in one exec (mode change resets gamma)
if grep -Fq 'xrandr --output DP-1 --mode 3440x1440 --rate 120.00; exec dex --autostart --environment i3' \
    "$ROOT/i3/config" \
  && ! grep -Fq 'xrandr --output DP-3' "$ROOT/i3/config" \
  && ! grep -Eq '^exec --no-startup-id xrandr --output' "$ROOT/i3/config"; then
  pass "i3 chains xrandr then dex on DP-1; no standalone xrandr exec"
else
  fail "i3 must run xrandr --output DP-1 then dex in one sh -c (no DP-3, no later standalone xrandr)"
fi

# AC7 units invoke auto
if grep -Eq 'apply\.sh[" ]+auto' "$ROOT/systemd/user/appearance.service" \
  && grep -Fq 'OnCalendar=hourly' "$ROOT/systemd/user/appearance.timer" \
  && grep -Eq 'apply\.sh[" ]+auto' "$ROOT/autostart/appearance.desktop"; then
  pass "login + hourly invoke auto"
else
  fail "service/timer/desktop must invoke apply.sh auto / hourly"
fi

if [[ -f "$home/.local/state/appearance/kitty.conf" ]] \
  && grep -Fq 'background #1e1e2e' "$home/.local/state/appearance/kitty.conf"; then
  pass "install seeds mocha kitty.conf in state dir"
else
  fail "install.sh must seed ~/.local/state/appearance/kitty.conf"
fi

exit "$FAIL"
