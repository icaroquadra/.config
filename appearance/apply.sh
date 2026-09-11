#!/usr/bin/env bash
# GTK + kitty + tmux + fish light/dark from schedule. See docs/specs/eye-comfort.md
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$HERE/.." && pwd)"
CONF="${APPEARANCE_CONF:-${XDG_CONFIG_HOME:-$HOME/.config}/appearance/schedule.conf}"
STATE="${APPEARANCE_STATE:-$HOME/.local/state/appearance}"
KITTY_SOCK_DIR="${KITTY_SOCK_DIR:-$HOME/.cache/kitty}"

DAY_START=07:00
DAY_END=18:00
if [[ -f "$CONF" ]]; then
  # shellcheck disable=SC1090
  source "$CONF"
fi

to_min() {
  local h m
  IFS=: read -r h m <<<"$1"
  echo $((10#$h * 60 + 10#$m))
}

now_hm() {
  if [[ -n "${APPEARANCE_NOW:-}" ]]; then
    echo "$APPEARANCE_NOW"
    return
  fi
  date +%H:%M
}

gset() {
  command -v gsettings >/dev/null 2>&1 || return 0
  gsettings set "$@"
}

install_theme_files() {
  local mode="$1"
  mkdir -p "$STATE"
  local k="$DOTFILES/kitty/themes/${mode}.conf"
  local t="$DOTFILES/tmux/themes/${mode}.conf"
  [[ -f "$k" ]] && cp -f "$k" "$STATE/kitty.conf"
  [[ -f "$t" ]] && cp -f "$t" "$STATE/tmux.conf"
}

reload_kitty() {
  command -v kitty >/dev/null 2>&1 || return 0
  local theme="$STATE/kitty.conf"
  [[ -f "$theme" ]] || return 0
  local sock
  shopt -s nullglob
  for sock in "$KITTY_SOCK_DIR"/*.sock; do
    kitty @ --to "unix:$sock" set-colors --all --configured "$theme" || true
  done
}

reload_tmux() {
  command -v tmux >/dev/null 2>&1 || return 0
  local theme="$STATE/tmux.conf"
  [[ -f "$theme" ]] || return 0
  tmux has-session 2>/dev/null || return 0
  tmux source-file "$theme" || true
}

apply_fish() {
  local script="$DOTFILES/fish/themes/${1}.fish"
  [[ -f "$script" ]] || return 0
  command -v fish >/dev/null 2>&1 || return 0
  fish "$script" || true
}

apply_day() {
  gset org.gnome.desktop.interface color-scheme prefer-light
  gset org.gnome.desktop.interface gtk-theme Adwaita
  install_theme_files day
  reload_kitty
  reload_tmux
  apply_fish day
}

apply_night() {
  gset org.gnome.desktop.interface color-scheme prefer-dark
  gset org.gnome.desktop.interface gtk-theme Adwaita-dark
  install_theme_files night
  reload_kitty
  reload_tmux
  apply_fish night
}

mode="${1:-auto}"
case "$mode" in
  day) apply_day ;;
  night) apply_night ;;
  auto)
    now="$(to_min "$(now_hm)")"
    start="$(to_min "$DAY_START")"
    end="$(to_min "$DAY_END")"
    if ((now >= start && now < end)); then
      apply_day
    else
      apply_night
    fi
    ;;
  *)
    echo "usage: apply.sh day|night|auto" >&2
    exit 2
    ;;
esac
