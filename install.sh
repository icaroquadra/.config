#!/usr/bin/env bash
# Liga os arquivos deste repositório em ~/.config e no $HOME.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

link() {
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    echo "  $dest -> $src"
}

echo "Dotfiles em $ROOT"
echo

echo "~/.config"
link "$ROOT/fish"           "$CONFIG/fish"
link "$ROOT/i3"             "$CONFIG/i3"
link "$ROOT/i3status"       "$CONFIG/i3status"
link "$ROOT/kitty"          "$CONFIG/kitty"
link "$ROOT/nvim"           "$CONFIG/nvim"
link "$ROOT/rofi"           "$CONFIG/rofi"
link "$ROOT/lazygit"        "$CONFIG/lazygit"
link "$ROOT/starship.toml"  "$CONFIG/starship.toml"
# Debian AppArmor: redshift may only read @{HOME}/.config/redshift.conf (not a symlink target).
if [[ -L "$CONFIG/redshift" ]]; then
    rm -f "$CONFIG/redshift"
fi
cp -f "$ROOT/redshift/redshift.conf" "$CONFIG/redshift.conf"
echo "  $CONFIG/redshift.conf copied"
link "$ROOT/appearance"             "$CONFIG/appearance"
rm -f "$CONFIG/autostart/redshift-gtk.desktop"
link "$ROOT/autostart/redshift.desktop"      "$CONFIG/autostart/redshift.desktop"
link "$ROOT/autostart/appearance.desktop"   "$CONFIG/autostart/appearance.desktop"
link "$ROOT/systemd/user/appearance.service" "$CONFIG/systemd/user/appearance.service"
link "$ROOT/systemd/user/appearance.timer"   "$CONFIG/systemd/user/appearance.timer"
chmod +x "$ROOT/appearance/apply.sh"
mkdir -p "$HOME/.local/state/appearance" "$HOME/.cache/kitty"
if [[ ! -f "$HOME/.local/state/appearance/kitty.conf" ]]; then
    cp -f "$ROOT/kitty/themes/night.conf" "$HOME/.local/state/appearance/kitty.conf"
    cp -f "$ROOT/tmux/themes/night.conf" "$HOME/.local/state/appearance/tmux.conf"
    echo "  seeded $HOME/.local/state/appearance/{kitty,tmux}.conf"
fi

echo
echo "Cursor"
mkdir -p "$CONFIG/Cursor/User" "$HOME/.cursor"
link "$ROOT/cursor/settings.json"    "$CONFIG/Cursor/User/settings.json"
if [[ -f "$ROOT/cursor/keybindings.json" ]]; then
    link "$ROOT/cursor/keybindings.json" "$CONFIG/Cursor/User/keybindings.json"
fi
if [[ -d "$ROOT/cursor/skills" ]]; then
    link "$ROOT/cursor/skills" "$HOME/.cursor/skills"
fi

echo
echo "$HOME"
link "$ROOT/bashrc"      "$HOME/.bashrc"
link "$ROOT/.tmux.conf"  "$HOME/.tmux.conf"

if [[ -z "${DOTFILES_SKIP_SYSTEMD:-}" ]] && command -v systemctl >/dev/null 2>&1; then
    if systemctl --user show-environment >/dev/null 2>&1; then
        systemctl --user daemon-reload
        systemctl --user enable --now appearance.timer
        echo
        echo "systemd --user: appearance.timer enabled"
    fi
fi

echo
echo "Concluído. Shell padrão: fish (plugins: fisher install em ~/.config/fish)."
echo "Fontes opcionais: copie fonts/*.ttf para ~/.local/share/fonts/ e fc-cache -fv"
echo "Eye comfort: sudo apt install redshift  (docs/specs/eye-comfort.md)"
