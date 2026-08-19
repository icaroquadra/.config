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
link "$ROOT/tmux"           "$CONFIG/tmux"
link "$ROOT/starship.toml"  "$CONFIG/starship.toml"

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
# tmux reads ~/.tmux.conf or ~/.config/tmux/tmux.conf (first wins).
# Keep both pointing at the same file so either path works.
link "$ROOT/tmux/tmux.conf" "$HOME/.tmux.conf"

echo
echo "tmux plugin manager"
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo "  cloned tpm -> $HOME/.tmux/plugins/tpm"
else
    echo "  $HOME/.tmux/plugins/tpm (já instalado)"
fi

echo
echo "Concluído. Shell padrão: fish (plugins: fisher install em ~/.config/fish)."
echo "tmux: prefix + I instala plugins. Fontes opcionais: copie fonts/*.ttf para ~/.local/share/fonts/ e fc-cache -fv"
