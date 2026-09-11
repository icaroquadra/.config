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
| `redshift/redshift.conf` | `~/.config/redshift.conf` (**copy**, AppArmor) |
| `appearance/` | `~/.config/appearance` |
| `autostart/*.desktop` | `~/.config/autostart/` |
| `systemd/user/appearance.*` | `~/.config/systemd/user/` |
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

## Instalação (máquina já configurada)

```bash
cd ~/meu/config   # ou clone: git@github.com:icaroquadra/.config.git
chmod +x install.sh
./install.sh
```

## Debian novo

```bash
sudo apt-get install -y git
git clone git@github.com:icaroquadra/.config.git ~/meu/config
cd ~/meu/config
./bootstrap-debian.sh          # apt + install.sh + chsh fish
# já tem GDM/X:
./bootstrap-debian.sh --skip-x11
```

Spec: `docs/specs/debian-bootstrap.md`. Bootstrap **não** instala Chrome, Cursor, Discord, Slack, Spotify, Postman, Android Studio, Obsidian — você instala se quiser.

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
- **Eye comfort:** redshift daemon (6500K day / 3500K night, 07:00–18:00) + GTK light/dark (`docs/specs/eye-comfort.md`)
- **Terminal:** kitty + [fish](https://fishshell.com/) + [starship](https://starship.rs/)
- **Multiplexador:** tmux (sessão `default` no fish)
- **Editor terminal:** [Neovim](https://neovim.io/) + [LazyVim](https://www.lazyvim.org/)
- **IDE:** Cursor (`cursor/settings.json`, `cursor/keybindings.json`)

Nova máquina: `./bootstrap-debian.sh` (`docs/specs/debian-bootstrap.md`).

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

## Eye comfort + tema claro/escuro

Horário em dois arquivos (manter iguais): `appearance/schedule.conf` e `redshift/redshift.conf` (`dawn-time` / `dusk-time`).

```bash
sudo apt install redshift
./install.sh          # links + enable appearance.timer
# sessão atual:
redshift &
~/.config/appearance/apply.sh auto
# kitty: fechar e abrir uma vez (socket remote control)
tmux source-file ~/.tmux.conf
```

Kitty Latte/Mocha, tmux status, fish `set -U`. Starship/nvim/Cursor fora. Restart kitty **uma vez** após este install.

Próximo login: `dex` sobe redshift + apply (já tem `dex --autostart --environment i3` no i3). Timer user aplica `auto` cada hora.
