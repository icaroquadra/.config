-- OS appearance → colorscheme. Spec: docs/specs/os-theme.md
local M = {}

M.LIGHT_SCHEME = "catppuccin-latte"
M.DARK_SCHEME = "vscode"

function M.scheme_for(appearance)
  if appearance == "light" then
    return M.LIGHT_SCHEME
  end
  return M.DARK_SCHEME
end

function M.portal_uint(stdout)
  local s = tostring(stdout or "")
  return tonumber(s:match("uint32%s+(%d+)") or s:match("(%d+)%D*$"))
end

function M.appearance_from_portal(value)
  if tonumber(value) == 2 then
    return "light"
  end
  return "dark"
end

function M.appearance_from_portal_stdout(stdout)
  return M.appearance_from_portal(M.portal_uint(stdout))
end

function M.appearance_from_gsettings(stdout)
  if tostring(stdout or ""):find("prefer%-light", 1, false) then
    return "light"
  end
  return "dark"
end

local function run(cmd)
  if vim and vim.fn and vim.fn.system then
    return vim.fn.system(cmd)
  end
  return ""
end

function M.detect_os_appearance(runner)
  runner = runner or run
  local portal = runner({
    "gdbus",
    "call",
    "--session",
    "--dest",
    "org.freedesktop.portal.Desktop",
    "--object-path",
    "/org/freedesktop/portal/desktop",
    "--method",
    "org.freedesktop.portal.Settings.Read",
    "org.freedesktop.appearance",
    "color-scheme",
  })
  local n = M.portal_uint(portal)
  if n ~= nil then
    if n == 2 then
      return "light"
    end
    if n ~= 0 then
      return "dark"
    end
  end
  local gs = runner({
    "gsettings",
    "get",
    "org.gnome.desktop.interface",
    "color-scheme",
  })
  return M.appearance_from_gsettings(gs)
end

function M.apply(appearance)
  appearance = appearance == "light" and "light" or "dark"
  vim.o.background = appearance
  vim.cmd.colorscheme(M.scheme_for(appearance))
end

function M.apply_from_os()
  M.apply(M.detect_os_appearance())
end

return M
