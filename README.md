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
| `starship.toml` | `~/.config/starship.toml` |
| `cursor/` | `~/.config/Cursor/User/` |
| `cursor/skills/` | `~/.cursor/skills/` (Agent Skills pessoais) |

### Cursor skills (`cursor/skills/`)

| Skill | Descrição |
|-------|-----------|
| `create-rule/` | Criar regras em `.cursor/rules/` |
| `productivity/caveman/` | Comunicação ultra-comprimida (~75% menos tokens) |
| `productivity/grill-me/` | Entrevista sobre plano/design até alinhar decisões |
| `productivity/handoff/` | Compactar conversa em doc de handoff |
| `productivity/teach/` | Ensinar conceito em sessões com workspace stateful |
| `productivity/write-a-skill/` | Criar novas skills com estrutura correta |

`productivity/*` vem de [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity) (MIT). Para atualizar: sparse-clone ou `npx skills@latest add mattpocock/skills`.

| `bashrc` | `~/.bashrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `fonts/` | `~/.local/share/fonts/` (manual) |
| `archive/macos/` | legado (zsh, macOS) — não usado no Debian |

Arquivos **não** versionados (gerados na máquina): `fish_variables`, temas/completions do fisher.

## Instalação

```bash
cd ~/www/meu/config   # ou clone: git@github.com:icaroquadra/.config.git
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

## Stack

- **WM:** [i3](https://i3wm.org/) + i3status + rofi
- **Terminal:** kitty + [fish](https://fishshell.com/) + [starship](https://starship.rs/)
- **Multiplexador:** tmux (sessão `default` no fish)
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
