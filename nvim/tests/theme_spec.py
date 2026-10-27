#!/usr/bin/env python3
"""AC1–AC6 + plugin wiring. Canonical runner: nvim -l tests/theme_spec.lua"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
theme_lua = (ROOT / "lua/insideee-dev/theme.lua").read_text()
colors = (ROOT / "lua/plugins/colorscheme.lua").read_text()
lazy = (ROOT / "lua/config/lazy.lua").read_text()

failed = 0


def check(cond, name):
    global failed
    if not cond:
        failed += 1
        print(f"FAIL {name}", file=sys.stderr)


# AC1–AC3 source
check('LIGHT_SCHEME = "catppuccin-latte"' in theme_lua, "AC1 LIGHT_SCHEME")
check('DARK_SCHEME = "vscode"' in theme_lua, "AC2 DARK_SCHEME")
check('if appearance == "light"' in theme_lua, "AC1/2 scheme_for light branch")
check("return M.DARK_SCHEME" in theme_lua, "AC3 default dark scheme")

# AC4
check("function M.portal_uint" in theme_lua, "AC4 portal_uint")
check("uint32%s+(%d+)" in theme_lua, "AC4 parse uint32 payload")
check("tonumber(value) == 2" in theme_lua, "AC4 portal 2 -> light")

# AC5
check("prefer%-light" in theme_lua, "AC5 gsettings prefer-light")

# AC6
check("gdbus" in theme_lua, "AC6 portal gdbus")
check("gsettings" in theme_lua, "AC6 gsettings fallback")
check(re.search(r"~= 0", theme_lua) is not None, "AC6 portal 0 fallthrough")

# AC7–AC8 plugin
check("auto-dark-mode.nvim" in colors, "AC7 auto-dark-mode")
check('apply("light")' in colors, "AC7 set_light_mode")
check('apply("dark")' in colors, "AC7 set_dark_mode")
check('flavour = "latte"' in colors, "catppuccin flavour latte")
check('theme = "auto"' in colors, "AC8 lualine auto")
check("catppuccin-latte" in lazy, "lazy install latte")
check('style = "dark"' in colors, "vscode forced dark")


def scheme_for(appearance):
    return "catppuccin-latte" if appearance == "light" else "vscode"


def portal_uint(stdout):
    s = str(stdout or "")
    m = re.search(r"uint32\s+(\d+)", s)
    if m:
        return int(m.group(1))
    m = re.search(r"(\d+)\D*$", s)
    return int(m.group(1)) if m else None


def appearance_from_portal(value):
    try:
        return "light" if int(value) == 2 else "dark"
    except (TypeError, ValueError):
        return "dark"


def appearance_from_portal_stdout(stdout):
    return appearance_from_portal(portal_uint(stdout))


def appearance_from_gsettings(stdout):
    return "light" if "prefer-light" in str(stdout or "") else "dark"


def detect_os_appearance(runner):
    n = portal_uint(runner(["gdbus"]))
    if n is not None:
        if n == 2:
            return "light"
        if n != 0:
            return "dark"
    return appearance_from_gsettings(runner(["gsettings"]))


check(scheme_for("light") == "catppuccin-latte", "AC1 scheme_for light")
check(scheme_for("dark") == "vscode", "AC2 scheme_for dark")
check(scheme_for(None) == "vscode", "AC3 scheme_for nil")
check(scheme_for("") == "vscode", "AC3 scheme_for empty")
check(appearance_from_portal(2) == "light", "AC4 portal 2")
check(appearance_from_portal(1) == "dark", "AC4 portal 1")
check(appearance_from_portal(0) == "dark", "AC4 portal 0")
check(appearance_from_portal_stdout("(<<uint32 2>>,)") == "light", "AC4 stdout 2")
check(portal_uint("(<<uint32 2>>,)") == 2, "AC4 portal_uint skips type digits")
check(appearance_from_gsettings("'prefer-light'") == "light", "AC5 prefer-light")
check(appearance_from_gsettings("'prefer-dark'") == "dark", "AC5 prefer-dark")
check(
    detect_os_appearance(lambda cmd: "(<<uint32 2>>,)" if cmd[0] == "gdbus" else "'prefer-dark'")
    == "light",
    "AC6 portal light wins",
)
check(
    detect_os_appearance(lambda cmd: "(<<uint32 0>>,)" if cmd[0] == "gdbus" else "'prefer-light'")
    == "light",
    "AC6 portal 0 -> gsettings",
)
check(detect_os_appearance(lambda _cmd: "") == "dark", "AC6 empty -> dark")

if failed:
    print(f"{failed} failed", file=sys.stderr)
    sys.exit(1)
print("ok")
