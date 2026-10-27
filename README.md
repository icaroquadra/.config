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
| `dunst/` | `~/.config/dunst` (notificações do Slack em amarelo) |
| `lazygit/` | `~/.config/lazygit` |
| `tmux/` | `~/.config/tmux` (`tmux.conf` também em `~/.tmux.conf`) |
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

Tmux — após linkar `tmux/` (Kitty já abre a sessão `default`):

```bash
tmux source-file ~/.config/tmux/tmux.conf
# prefix + I instala plugins (tpm, dracula, vim-tmux-navigator)
```

## Stack

- **WM:** [i3](https://i3wm.org/) + i3status + rofi
- **Eye comfort:** redshift daemon (5000K day / 3000K night, 2h ramps 06:00–08:00 and 17:00–19:00) + GTK light/dark (`docs/specs/eye-comfort.md`)
- **Terminal:** kitty + [fish](https://fishshell.com/) + [starship](https://starship.rs/)
- **Multiplexador:** tmux (sessão `default` no fish / kitty `shell`) — config em `tmux/tmux.conf`
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

Horário: redshift usa intervalos (`dawn-time=6:00-8:00`, `dusk-time=17:00-19:00`); GTK flip no meio (`appearance/schedule.conf` 07:00 / 18:00). `location-provider=manual` (lat/lon dummy): sem isso o binário pede GeoClue no login, não recebe fix, e sai antes de aplicar gamma.

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

Próximo login: i3 roda `xrandr` **depois** `dex` (redshift + apply). Sem isso, `xrandr --mode` zera gamma e a tela fica 6500K. `redshift -p` não prova que o daemon aplicou. Timer user aplica `auto` cada hora. Não use `i3-msg reload` pra testar (re-executa tudo).
