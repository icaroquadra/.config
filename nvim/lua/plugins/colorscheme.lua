return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
  {
    "catppuccin/nvim",
    enabled = false,
  },
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    opts = {
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
            theme = "vscode",
          },
        },
      },
    },
  },
}
