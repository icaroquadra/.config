-- spec: docs/specs/os-theme.md
local this = debug.getinfo(1, "S").source:sub(2)
local root = this:match("(.+)/tests/")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

local theme = require("insideee-dev.theme")

local failed = 0
local function eq(actual, expected, name)
  if actual ~= expected then
    failed = failed + 1
    io.stderr:write(string.format("FAIL %s: expected %q got %q\n", name, tostring(expected), tostring(actual)))
  end
end

-- AC1
eq(theme.scheme_for("light"), "catppuccin-latte", "AC1 light scheme")
-- AC2
eq(theme.scheme_for("dark"), "vscode", "AC2 dark scheme")
-- AC3
eq(theme.scheme_for(nil), "vscode", "AC3 nil -> dark")
eq(theme.scheme_for(""), "vscode", "AC3 empty -> dark")
eq(theme.scheme_for("no-preference"), "vscode", "AC3 unknown -> dark")
-- AC4
eq(theme.appearance_from_portal(2), "light", "AC4 portal 2")
eq(theme.appearance_from_portal(1), "dark", "AC4 portal 1")
eq(theme.appearance_from_portal(0), "dark", "AC4 portal 0")
eq(theme.appearance_from_portal(nil), "dark", "AC4 portal nil")
eq(theme.portal_uint("(<<uint32 2>>,)"), 2, "AC4 portal_uint skips type digits")
eq(theme.appearance_from_portal_stdout("(<<uint32 2>>,)"), "light", "AC4 portal stdout 2")
eq(theme.appearance_from_portal_stdout("(<<uint32 1>>,)"), "dark", "AC4 portal stdout 1")
eq(theme.appearance_from_portal_stdout(""), "dark", "AC4 portal stdout empty")
-- AC5
eq(theme.appearance_from_gsettings("'prefer-light'"), "light", "AC5 gsettings prefer-light")
eq(theme.appearance_from_gsettings("'prefer-dark'"), "dark", "AC5 gsettings prefer-dark")
eq(theme.appearance_from_gsettings("'default'"), "dark", "AC5 gsettings default")
eq(theme.appearance_from_gsettings(""), "dark", "AC5 gsettings empty")
-- AC6 detect: portal wins; 0 falls through to gsettings; else dark
eq(
  theme.detect_os_appearance(function(cmd)
    if cmd[1] == "gdbus" then
      return "(<<uint32 2>>,)"
    end
    return "'prefer-dark'"
  end),
  "light",
  "AC6 portal light wins"
)
eq(
  theme.detect_os_appearance(function(cmd)
    if cmd[1] == "gdbus" then
      return "(<<uint32 0>>,)"
    end
    return "'prefer-light'"
  end),
  "light",
  "AC6 portal 0 -> gsettings light"
)
eq(
  theme.detect_os_appearance(function()
    return ""
  end),
  "dark",
  "AC6 empty -> dark"
)

if failed > 0 then
  io.stderr:write(failed .. " failed\n")
  os.exit(1)
end
print("ok")
