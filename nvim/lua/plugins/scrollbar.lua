return {
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    opts = {
      handlers = {
        gitsigns = true,
        diagnostic = true,
        search = false,
      },
    },
    config = function(_, opts)
      require("scrollbar").setup(opts)
      require("scrollbar.handlers.gitsigns").setup()
    end,
  },
}
