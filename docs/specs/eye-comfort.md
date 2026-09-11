# Eye comfort + scheduled appearance

## Problem

Debian + i3 has no Night Shift / Eye Comfort. Need:

1. Warm screen at night (redshift, like Android Eye Comfort)
2. Light GTK by day, dark GTK by night
3. All of it versioned in this repo (`install.sh` links), not only on the live machine

## Scope

**In**

- Redshift color temperature (day / night)
- GTK `color-scheme` + Adwaita theme from a clock schedule
- Kitty palette, tmux status, fish `set -U` colors (Catppuccin Latte day / Mocha night)
- XDG autostart (dex already runs in i3)
- systemd user timer so a long session still flips at the hour
- Lat/lon not required: fixed `dawn-time` / `dusk-time`

**Out**

- i3bar / Cursor / nvim / rofi / starship palette swap
- Geoclue / sunrise math
- `darkman` (optional later; same hooks can call `appearance/apply.sh`)

## Behavior

### Redshift

| Window | Temperature | Brightness |
|--------|-------------|------------|
| Day `[07:00, 18:00)` | 6500K | 1.0 |
| Night | 3500K | 0.85 |

Fade on. Method `randr`. Times in `redshift/redshift.conf` must match `appearance/schedule.conf`.

### Appearance

`appearance/apply.sh`:

| Arg | Effect |
|-----|--------|
| `day` | `prefer-light`, GTK `Adwaita`, Kitty/tmux/fish **Latte** |
| `night` | `prefer-dark`, GTK `Adwaita-dark`, Kitty/tmux/fish **Mocha** |
| `auto` | `day` if now in `[DAY_START, DAY_END)`, else `night` |

Missing `gsettings` / `kitty` / `tmux` / `fish` → skip that piece, exit 0 (login must not fail).

Terminal palettes copy to `$HOME/.local/state/appearance/{kitty,tmux}.conf` (not inside repo-linked `~/.config/kitty`). `APPEARANCE_STATE` overrides that dir (tests).

Kitty live reload: `allow_remote_control socket-only` + `listen_on unix:${HOME}/.cache/kitty/{kitty_pid}.sock`. `apply.sh` runs `kitty @ set-colors` on each `*.sock`. Restart kitty once after this config so the socket exists.

Tmux: `source-file ~/.local/state/appearance/tmux.conf` if a server is up.
Fish: `fish fish/themes/{day,night}.fish` (`set -U` → all sessions).

`APPEARANCE_NOW=HH:MM` overrides clock (tests).
`APPEARANCE_CONF` overrides schedule path (tests).

### Start

- `~/.config/autostart/redshift.desktop` — headless `Exec=redshift`, `OnlyShowIn=i3` (no GTK tray)
- `~/.config/autostart/appearance.desktop` — `apply.sh auto` on login
- `appearance.timer` — hourly `apply.sh auto` (`OnCalendar=hourly`)

## Layout (repo → XDG)

| Repositório | Destino |
|-------------|---------|
| `redshift/redshift.conf` | **copy** `~/.config/redshift.conf` (AppArmor; not a symlink) |
| `appearance/` | `~/.config/appearance` |
| `autostart/redshift.desktop` | `~/.config/autostart/redshift.desktop` |
| `autostart/appearance.desktop` | `~/.config/autostart/appearance.desktop` |
| `systemd/user/appearance.service` | `~/.config/systemd/user/appearance.service` |
| `systemd/user/appearance.timer` | `~/.config/systemd/user/appearance.timer` |

`./install.sh` creates those links. systemd enable skipped when `DOTFILES_SKIP_SYSTEMD=1`.

## Packages

```bash
sudo apt install redshift
```

## Acceptance criteria

1. `install.sh` links every path in the layout table (under `HOME` / `XDG_CONFIG_HOME`). `redshift.conf` is copied to `~/.config/redshift.conf` (Debian AppArmor denies symlink targets).
2. `apply.sh day` runs `gsettings set org.gnome.desktop.interface color-scheme prefer-light` and gtk-theme `Adwaita`.
3. `apply.sh night` sets `prefer-dark` and `Adwaita-dark`.
4. `apply.sh auto` with `APPEARANCE_NOW=07:00` → day; `18:00` → night; `06:59` → night.
5. Missing `gsettings` → exit 0.
6. `redshift.conf` has `temp-day=6500`, `temp-night=3500`, `dawn-time=7:00`, `dusk-time=18:00`.
7. Login + hourly timer both invoke `auto` (desktop file + systemd unit).
8. i3 config unchanged; dex autostart picks the `.desktop` files.
9. `apply.sh day` copies Latte `background #eff1f5` into `$APPEARANCE_STATE/kitty.conf` and Latte tmux status; `night` copies Mocha `background #1e1e2e`.
10. `install.sh` seeds `$HOME/.local/state/appearance/kitty.conf` if missing (so kitty `include` does not fail).

## Assumptions

- Schedule 07:00–18:00. Edit `schedule.conf` **and** redshift dawn/dusk together.
- `dex --autostart --environment i3` already in i3 config.
- Open GTK apps may need restart to fully restyle.
- Open kitty windows pick new colors only if the listen socket exists (restart kitty once after install).
