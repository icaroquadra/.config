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

echo
echo "Cursor"
mkdir -p "$CONFIG/Cursor/User"
link "$ROOT/cursor/settings.json"    "$CONFIG/Cursor/User/settings.json"
if [[ -f "$ROOT/cursor/keybindings.json" ]]; then
    link "$ROOT/cursor/keybindings.json" "$CONFIG/Cursor/User/keybindings.json"
fi

echo
echo "$HOME"
link "$ROOT/bashrc"      "$HOME/.bashrc"
link "$ROOT/.tmux.conf"  "$HOME/.tmux.conf"

echo
echo "Concluído. Shell padrão: fish (plugins: fisher install em ~/.config/fish)."
echo "Fontes opcionais: copie fonts/*.ttf para ~/.local/share/fonts/ e fc-cache -fv"
