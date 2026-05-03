return {
  {
    "folke/snacks.nvim",
    opts = {
      -- No sidebar explorer.
      explorer = {
        enabled = false,
      },

      -- Lighter startup.
      dashboard = {
        enabled = false,
      },

      -- Less visual noise.
      indent = {
        enabled = false,
      },

      -- Keep picker behavior.
      picker = {
        hidden = true,
        ignored = false,
        sources = {
          files = {
            hidden = true,
            ignored = false,
          },
          grep = {
            hidden = true,
            ignored = false,
          },
        },
      },
    },
    keys = {
      -- Remove LazyVim explorer mappings so our picker mappings own these.
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
}
