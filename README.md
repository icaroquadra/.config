# Dotfiles (Debian + i3)

Configurações versionadas desta máquina. Estrutura espelha `~/.config` e alguns dotfiles em `$HOME`.

## Estrutura

| Repositório | Destino |
|-------------|---------|
| `fish/` | `~/.config/fish` |
| `i3/` | `~/.config/i3` |
| `i3status/` | `~/.config/i3status` |
| `kitty/` | `~/.config/kitty` |
| `nvim/` | `~/.config/nvim` (LazyVim) |
| `rofi/` | `~/.config/rofi` |
| `lazygit/` | `~/.config/lazygit` |
| `tmux/` | `~/.config/tmux` (`tmux.conf` também em `~/.tmux.conf`) |
| `starship.toml` | `~/.config/starship.toml` |
| `cursor/` | `~/.config/Cursor/User/` |
| `bashrc` | `~/.bashrc` |
| `fonts/` | `~/.local/share/fonts/` (manual) |
| `archive/macos/` | legado (zsh, macOS) — não usado no Debian |

Arquivos **não** versionados (gerados na máquina): `fish_variables`, temas/completions do fisher.

## Instalação

```bash
cd ~/meu/config   # ou clone: git@github.com:icaroquadra/.config.git
chmod +x install.sh
./install.sh
```

Fish — plugins declarados em `fish/fish_plugins`:

```bash
fisher install jorgebucaran/fisher
fisher update
```

Neovim — após linkar `nvim/`:

```bash
nvim   # LazyVim instala plugins na primeira abertura
```

Tmux — após linkar `tmux/` (Kitty já abre a sessão `default`):

```bash
tmux source-file ~/.config/tmux/tmux.conf
# prefix + I instala plugins (tpm, dracula, vim-tmux-navigator)
```

## Stack

- **WM:** [i3](https://i3wm.org/) + i3status + rofi
- **Terminal:** kitty + [fish](https://fishshell.com/) + [starship](https://starship.rs/)
- **Multiplexador:** tmux (sessão `default` no fish / kitty `shell`) — config em `tmux/tmux.conf`
- **Editor terminal:** [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/)
- **IDE:** Cursor (`cursor/settings.json`, `cursor/keybindings.json`)

## Atualizar o repositório a partir do sistema

Depois de mudar configs em `~/.config` ou no home:

```bash
cp -a ~/.config/fish/config.fish ~/.config/fish/fish_plugins fish/
cp ~/.config/fish/conf.d/* fish/conf.d/
cp ~/.config/i3/config i3/
# … ou copie os diretórios que alterou
git diff
```

Não commite `fish_variables` nem backups em `_backup_conflicts`.
