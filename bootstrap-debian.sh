#!/usr/bin/env bash
# Fresh Debian: apt packages from debian/packages*.txt, then install.sh, then chsh fish.
# See docs/specs/debian-bootstrap.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_RELEASE="${BOOTSTRAP_OS_RELEASE:-/etc/os-release}"

SKIP_X11=0
SKIP_DOTFILES=0
SKIP_CHSH=0
DRY_RUN=0

usage() {
  echo "usage: bootstrap-debian.sh [--dry-run] [--skip-x11] [--skip-dotfiles] [--skip-chsh]" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --skip-x11) SKIP_X11=1 ;;
    --skip-dotfiles) SKIP_DOTFILES=1 ;;
    --skip-chsh) SKIP_CHSH=1 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
  shift
done

is_debian() {
  [[ -f "$OS_RELEASE" ]] || return 1
  # shellcheck disable=SC1090
  . "$OS_RELEASE"
  [[ "${ID:-}" == debian ]] && return 0
  [[ "${ID_LIKE:-}" == *debian* ]] && return 0
  return 1
}

if [[ -z "${BOOTSTRAP_FORCE:-}" ]] && ! is_debian; then
  echo "bootstrap-debian.sh: not Debian (see $OS_RELEASE). Set BOOTSTRAP_FORCE=1 to override." >&2
  exit 2
fi

read_packages() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  grep -vE '^[[:space:]]*(#|$)' "$f" | sed 's/[[:space:]]*$//'
}

mapfile -t PKGS < <(read_packages "$ROOT/debian/packages.txt")
if [[ "$SKIP_X11" -eq 0 ]]; then
  mapfile -t X11 < <(read_packages "$ROOT/debian/packages-x11.txt")
  PKGS+=("${X11[@]}")
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '%s\n' "${PKGS[@]}"
  exit 0
fi

apt_cmd() {
  if [[ -n "${BOOTSTRAP_APT:-}" ]]; then
    "${BOOTSTRAP_APT}" "$@"
    return
  fi
  if [[ "${EUID}" -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get "$@"
  else
    sudo DEBIAN_FRONTEND=noninteractive apt-get "$@"
  fi
}

echo "apt-get update"
apt_cmd update
echo "apt-get install (${#PKGS[@]} packages)"
apt_cmd install -y "${PKGS[@]}"

if [[ "$SKIP_DOTFILES" -eq 0 ]]; then
  install_sh="${BOOTSTRAP_INSTALL:-$ROOT/install.sh}"
  echo "dotfiles: $install_sh"
  bash "$install_sh"
fi

if [[ "$SKIP_CHSH" -eq 0 ]] && command -v fish >/dev/null 2>&1; then
  fish_path="$(command -v fish)"
  if [[ "${SHELL:-}" != "$fish_path" ]]; then
    echo "chsh -s $fish_path"
    chsh -s "$fish_path"
  fi
fi

if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  echo "  $HOME/.local/bin/fd -> fdfind"
fi

cat <<'EOF'

Next (network / first login):
  fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher update'
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  # tmux: prefix + I
  nvim   # LazyVim first run
  ~/.config/appearance/apply.sh auto

Log out, pick i3 (LightDM session). Kitty: open once after apply so remote-control socket exists.
EOF
