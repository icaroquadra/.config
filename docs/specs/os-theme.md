# OS appearance → Neovim colorscheme

## Problem and scope

Follow OS light/dark like Cursor. Light = Catppuccin Latte. Dark = vscode dark (current).

**In**

- Map OS appearance to colorscheme
- Apply on startup
- Re-apply when OS appearance changes (plugin)

**Out**

- Catppuccin dark flavors (Mocha/Frappé/Macchiato)
- vscode light
- Android Studio / Cursor settings

## Behavior

| Appearance | `vim.o.background` | Colorscheme |
|---|---|---|
| light | `light` | `catppuccin-latte` |
| dark | `dark` | `vscode` |
| unknown / no preference | `dark` | `vscode` |

**xdg-desktop-portal `color-scheme`**

Parse `uint32 <n>` from gdbus stdout (not the digits inside the word `uint32`).

| Value | Appearance |
|---|---|
| 2 | light |
| 1 | dark |
| 0 / missing / unparsable | dark |

**gsettings `org.gnome.desktop.interface color-scheme`**

| stdout contains | Appearance |
|---|---|
| `prefer-light` | light |
| anything else | dark |

## Acceptance criteria

1. `scheme_for("light")` returns `catppuccin-latte`
2. `scheme_for("dark")` returns `vscode`
3. `scheme_for` for any other/empty value returns `vscode`
4. Portal uint `2` → light; `1` → dark; `0` → dark. Stdout `(<<uint32 2>>,)` → light (must not read `32` from `uint32`)
5. gsettings stdout with `prefer-light` → light; `prefer-dark` → dark
6. Startup applies scheme from OS (portal, else gsettings, else dark)
7. OS appearance change while nvim runs updates scheme
8. lualine follows the active colorscheme (`theme = "auto"`)
