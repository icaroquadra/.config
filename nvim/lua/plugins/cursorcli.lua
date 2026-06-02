-- Cursor Agent CLI (`agent`) inside Neovim — uses your existing Cursor login
-- https://github.com/suiramdev/cursorcli.nvim
-- Keymaps use <leader>A (capital A) to avoid Copilot (<leader>a…)
return {
  {
    "suiramdev/cursorcli.nvim",
    cmd = {
      "CursorCliOpen",
      "CursorCliOpenWithLayout",
      "CursorCliClose",
      "CursorCliRestart",
      "CursorCliResume",
      "CursorCliNew",
      "CursorCliSelect",
      "CursorCliRename",
      "CursorCliListSessions",
      "CursorCliAddSelection",
      "CursorCliFixErrorAtCursor",
      "CursorCliFixErrorAtCursorInNewSession",
      "CursorCliAddVisualSelectionToNewSession",
      "CursorCliQuickEdit",
    },
    opts = {
      command = { "agent" },
      auto_insert = true,
      notify = true,
      path = { relative_to_cwd = true },
      position = "float",
      float = {
        width = 0.9,
        height = 0.85,
        border = "rounded",
      },
    },
    keys = {
      { "<leader>A", "", desc = "+cursor agent" },
      { "<leader>Ag", "<Cmd>CursorCliOpenWithLayout float<CR>", desc = "Cursor Agent (float)", mode = "n" },
      { "<leader>Av", "<Cmd>CursorCliOpenWithLayout vsplit<CR>", desc = "Cursor Agent (vsplit)", mode = "n" },
      { "<leader>Ah", "<Cmd>CursorCliOpenWithLayout hsplit<CR>", desc = "Cursor Agent (hsplit)", mode = "n" },
      { "<leader>Ac", function() require("cursorcli").close() end, desc = "Close Cursor Agent", mode = "n" },
      { "<leader>An", function() require("cursorcli").new_chat() end, desc = "New Cursor Agent chat", mode = "n" },
      { "<leader>Ap", function() require("cursorcli").select_chat() end, desc = "Pick Cursor Agent chat", mode = "n" },
      { "<leader>Ar", function() require("cursorcli").resume() end, desc = "Resume Cursor Agent", mode = "n" },
      { "<leader>Ax", function() require("cursorcli").restart() end, desc = "Restart Cursor Agent session", mode = "n" },
      { "<leader>Al", function() require("cursorcli").list_sessions() end, desc = "List Cursor Agent sessions", mode = "n" },
      {
        "<leader>As",
        function() require("cursorcli").add_visual_selection() end,
        desc = "Send selection to Cursor Agent",
        mode = "x",
      },
      {
        "<leader>Af",
        function() require("cursorcli").request_fix_error_at_cursor() end,
        desc = "Fix error at cursor (Cursor Agent)",
        mode = "n",
      },
      {
        "<leader>AN",
        function() require("cursorcli").request_fix_error_at_cursor_in_new_session() end,
        desc = "New session: fix error at cursor",
        mode = "n",
      },
      {
        "<leader>AN",
        function() require("cursorcli").add_visual_selection_to_new_session() end,
        desc = "New session: send selection",
        mode = "x",
      },
    },
  },
}
