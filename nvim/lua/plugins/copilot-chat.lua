-- Override deprecated default gpt-4.1 (removed by GitHub ~2026-06).
-- Upstream default now gpt-5-mini; pin here so Lock lag cannot break chat.
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "gpt-5-mini",
    },
  },
}
