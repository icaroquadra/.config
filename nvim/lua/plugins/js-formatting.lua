--- Formatação JS/TS ao salvar via Prettier (conform.nvim).
--- Fallback quando não há .prettierrc no projeto — alinhado ao padrão Prettier 3 / mercado.

local prettier_args = {
  "--single-quote",
  "--semi",
  "--tab-width",
  "2",
  "--trailing-comma",
  "all",
  "--print-width",
  "100",
  "--arrow-parens",
  "always",
  "--end-of-line",
  "lf",
}

local js_filetypes = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
  "json",
  "jsonc",
}

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "prettier" },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(js_filetypes) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = vim.tbl_deep_extend("force", opts.formatters.prettier or {}, {
        -- .prettierrc do projeto tem prioridade; estes args valem fora de repos configurados
        prepend_args = prettier_args,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        jsonls = {
          on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },
}
