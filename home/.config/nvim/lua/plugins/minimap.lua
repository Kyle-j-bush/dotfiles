return {
  {
    "nvim-mini/mini.map",
    version = false,
    event = "VeryLazy",
    config = function()
      local map = require("mini.map")

      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
          map.gen_integration.gitsigns(),
        },

        symbols = {
          encode = map.gen_encode_symbols.dot("4x2"),
          scroll_line = "█",
          scroll_view = "┃",
        },

        window = {
          focusable = true,
          side = "right",
          show_integration_count = false,
          width = 10,
          winblend = 20,
          zindex = 10,
        },
      })

      vim.keymap.set("n", "<leader>mm", MiniMap.toggle, { desc = "Toggle minimap" })
      vim.keymap.set("n", "<leader>mo", MiniMap.open, { desc = "Open minimap" })
      vim.keymap.set("n", "<leader>mc", MiniMap.close, { desc = "Close minimap" })
      vim.keymap.set("n", "<leader>mf", MiniMap.toggle_focus, { desc = "Focus minimap" })
      vim.keymap.set("n", "<leader>mr", MiniMap.refresh, { desc = "Refresh minimap" })
      vim.keymap.set("n", "<leader>ms", MiniMap.toggle_side, { desc = "Toggle minimap side" })
    end,
  },
}
