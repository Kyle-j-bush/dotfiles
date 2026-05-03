return {
  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local fm = require("fluoromachine")

      fm.setup({
        glow = true,
        theme = "retrowave",
        transparent = false,
        brightness = 0.05,
        plugins = {
          bufferline = false,
          dashboard = false,
          neotree = false,
          tree = false,
          telescope = true,
          treesitter = true,
          cmp = true,
          gitsign = true,
          lazy = true,
          lspconfig = true,
          notify = true,
          noice = true,
          wk = true,
          editor = true,
          syntax = true,
        },
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "fluoromachine",
    },
  },
}
