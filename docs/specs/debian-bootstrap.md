# New Debian bootstrap

## Problem

Fresh Debian needs many packages before `install.sh` links work (i3, kitty, fish, tmux, redshift, …). Manual apt is easy to forget.

## Scope

**In**

- `debian/packages.txt` — WM + terminal + appearance + nvim deps (Debian 13 / trixie names)
- `debian/packages-x11.txt` — Xorg + LightDM (bare netinst)
- `bootstrap-debian.sh` — apt install, then `install.sh`, then `chsh` to fish
- Dry-run and test doubles (`BOOTSTRAP_APT`, `BOOTSTRAP_OS_RELEASE`)

**Out**

- Vendor apps: Chrome, Cursor, Discord, Slack, Spotify, Postman, Android Studio, Obsidian
- Building a custom ISO
- Auto-install fisher/tpm/LazyVim plugins (print commands only; needs network + first GUI login)

## Behavior

```bash
./bootstrap-debian.sh              # apt + install.sh + chsh
./bootstrap-debian.sh --dry-run    # print packages, exit 0, no apt
./bootstrap-debian.sh --skip-x11   # no xorg/lightdm (already have GDM/X)
./bootstrap-debian.sh --skip-dotfiles
./bootstrap-debian.sh --skip-chsh
```

1. Abort exit 2 unless `/etc/os-release` `ID=debian` or `ID_LIKE` contains debian (override path: `BOOTSTRAP_OS_RELEASE`). `BOOTSTRAP_FORCE=1` skips check.
2. Read package lists (skip `#` and blank).
3. `apt-get update` then `apt-get install -y` (via `sudo` if not root). `BOOTSTRAP_APT` replaces the apt-get binary.
4. Unless `--skip-dotfiles`: run `./install.sh` (`DOTFILES_SKIP_SYSTEMD` still honored).
5. Unless `--skip-chsh`: `chsh -s` fish if login shell is not already fish.
6. Print next-step commands (fisher, tpm, nvim, reboot/i3).

`--dry-run` stops after printing the resolved package list.

## Acceptance criteria

1. `--dry-run` on a debian os-release fixture prints `i3`, `kitty`, `fish`, `tmux`, `redshift`, `neovim` and exit 0; does not invoke apt.
2. `--dry-run` without `--skip-x11` also prints `xorg` and `lightdm`.
3. `--dry-run --skip-x11` does not print `lightdm`.
4. Non-debian os-release → exit 2, no apt.
5. With `BOOTSTRAP_APT` mock and `--skip-chsh --skip-dotfiles`, mock log contains `update` and `install -y` plus `i3`.
6. Default run (mocked apt + mocked install) invokes `install.sh`.
8. `--dry-run` / `debian/packages*.txt` do **not** include Chrome, Chromium, Cursor, Discord, Slack, Spotify, Postman, Android Studio, or Obsidian.

## Assumptions

- Repo already cloned (git installed by hand or debian installer).
- Debian 13 (trixie) package names.
- LightDM only for machines without a display manager yet.
