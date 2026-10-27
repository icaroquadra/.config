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
- Clock schedule via `dawn-time` / `dusk-time` (solar elevation unused)
- Redshift still exits at startup if no location provider answers. `location-provider=manual` plus dummy `lat`/`lon` satisfies that check. GeoClue stays out. Dummy coords do not drive color.

**Out**

- i3bar / Cursor / nvim / rofi / starship palette swap
- Geoclue (startup must not wait on it; see manual provider above)
- Sunrise math (dawn/dusk ranges replace it)
- `darkman` (optional later; same hooks can call `appearance/apply.sh`)

## Behavior

### Redshift

A single `HH:MM` is an **instant** switch (`7:00` = `7:00-7:00`). Ranges interpolate color temp + brightness. `fade=1` only eases start/stop (~seconds), not dawn/dusk.

| Window | Temperature | Brightness |
|--------|-------------|------------|
| Dawn `[06:00, 08:00)` | interpolate 3000K → 5000K | interpolate 0.85 → 1.0 |
| Day `[08:00, 17:00)` | 5000K | 1.0 |
| Dusk `[17:00, 19:00)` | interpolate 5000K → 3000K | interpolate 1.0 → 0.85 |
| Night | 3000K | 0.85 |

Method `randr`. `dawn-time=6:00-8:00`, `dusk-time=17:00-19:00`. Appearance `DAY_START`/`DAY_END` stay **midpoints** (07:00 / 18:00) — GTK cannot interpolate.

`location-provider=manual` with `[manual]` `lat=0.0` / `lon=0.0`. Without a provider, redshift tries GeoClue2, gets no fix at login, and exits before gamma. Dummy coords are ignored while both dawn and dusk ranges are set.

### Appearance

`appearance/apply.sh`:

| Arg | Effect |
|-----|--------|
| `day` | `prefer-light`, GTK `Adwaita`, Kitty/tmux/fish **Latte** |
| `night` | `prefer-dark`, GTK `Adwaita-dark`, Kitty/tmux/fish **Mocha** |
| `auto` | `day` if now in `[DAY_START, DAY_END)`, else `night` |

Missing `gsettings` / `kitty` / `tmux` / `fish` → skip that piece, exit 0 (login must not fail).

Terminal palettes copy to `$HOME/.local/state/appearance/{kitty,tmux}.conf` and `kitty/current-theme.conf` (gitignored; relative `include` so kitty does not need `${HOME}`).

Kitty live reload: `pkill -USR1 -x kitty` (reload config) plus `kitty @ set-colors` on `~/.cache/kitty/*.sock` if those exist.

Tmux: Catppuccin plugin (`~/.tmux/plugins/catppuccin`, not TPM `dracula/tmux`). Day `@catppuccin_flavor latte` + `window-style` Latte bg; night mocha. `apply.sh` re-runs `catppuccin.tmux` after setting flavor.
Fish: `fish fish/themes/{day,night}.fish` (`set -U` → all sessions).

`APPEARANCE_NOW=HH:MM` overrides clock (tests).
`APPEARANCE_CONF` overrides schedule path (tests).

### Start

i3 `exec` lines are **parallel**. `xrandr --mode` resets RandR gamma. If redshift starts before that, screen stays default (6500K) even when the daemon is alive. `redshift -p` only prints the calculated temp; it does not prove gamma is applied.

- i3: one `sh -c` runs `xrandr --output DP-1 --mode 3440x1440 --rate 120.00` **then** `dex --autostart --environment i3` (no second standalone `xrandr` exec)
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
6. `redshift.conf` has `temp-day=5000`, `temp-night=3000`, `dawn-time=6:00-8:00`, `dusk-time=17:00-19:00`, `location-provider=manual`, and `[manual]` `lat=0.0` / `lon=0.0`.
7. Login + hourly timer both invoke `auto` (desktop file + systemd unit).
8. i3 chains `xrandr --output DP-1 --mode 3440x1440 --rate 120.00` then `dex --autostart --environment i3` in one `sh -c`; no standalone `exec xrandr`. Dex still picks the `.desktop` files. Output is the connected ultrawide under modesetting/nouveau (`DP-1`). `DP-3` is disconnected (NVIDIA proprietary names).
9. `apply.sh day` copies Latte `background #eff1f5` into `$APPEARANCE_STATE/kitty.conf` and `@catppuccin_flavor "latte"` plus `window-style` `bg=#eff1f5`; `night` copies Mocha `background #1e1e2e` / flavor mocha.
10. `install.sh` seeds `$HOME/.local/state/appearance/kitty.conf` if missing (so kitty `include` does not fail).

## Assumptions

- Redshift ramps 2h around 07:00 / 18:00. GTK flip stays `[07:00, 18:00)`. Edit `schedule.conf` midpoints **and** redshift ranges together.
- i3 starts dex **after** xrandr so redshift attaches to the final CRTC. Do not `i3-msg reload` to test (re-runs every `exec`). Wrong `--output` (disconnected) skips the mode change; `;` still starts dex so redshift can live while the panel stays at the X default (60 Hz).
- This machine: modesetting/nouveau names the MG80034 ultrawide `DP-1`. Proprietary NVIDIA used `DP-3` / `DP-0`. Hardcode the connected name; do not target a disconnected output.
- Open GTK apps may need restart to fully restyle.
- Open kitty windows pick new colors only if the listen socket exists (restart kitty once after install).
