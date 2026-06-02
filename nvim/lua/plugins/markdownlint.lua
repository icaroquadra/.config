return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local cfg_default = vim.fn.stdpath("config") .. "/markdownlint-cli2.yaml"
      local cfg_md = vim.fn.stdpath("config") .. "/markdownlint-cli2-md.yaml"
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = vim.tbl_deep_extend("force", opts.linters["markdownlint-cli2"] or {}, {
        args = {
          "--config",
          function()
            local filename = vim.api.nvim_buf_get_name(0)
            if filename:sub(-3) == ".md" then
              return cfg_md
            end
            return cfg_default
          end,
          "--stdin-filepath",
          function()
            return vim.api.nvim_buf_get_name(0)
          end,
          "-",
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      local cfg_default = vim.fn.stdpath("config") .. "/markdownlint-cli2.yaml"
      local cfg_md = vim.fn.stdpath("config") .. "/markdownlint-cli2-md.yaml"
      opts.formatters = opts.formatters or {}
      opts.formatters["markdownlint-cli2"] = vim.tbl_deep_extend("force", opts.formatters["markdownlint-cli2"] or {}, {
        args = function(_, ctx)
          local cfg = ctx.filename:sub(-3) == ".md" and cfg_md or cfg_default
          return { "--config", cfg, "--fix", ctx.filename }
        end,
      })
    end,
  },
}
