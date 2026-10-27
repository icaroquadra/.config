return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require("insideee-dev.theme").apply_from_os()
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "latte",
    },
  },
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "dark",
      transparent = false,
      italic_comments = true,
      italic_inlayhints = true,
      underline_links = true,
      disable_nvimtree_bg = true,
      terminal_colors = true,
    },
    specs = {
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = {
          options = {
            theme = "auto",
          },
        },
      },
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    opts = {
      set_dark_mode = function()
        require("insideee-dev.theme").apply("dark")
      end,
      set_light_mode = function()
        require("insideee-dev.theme").apply("light")
      end,
    },
  },
}
