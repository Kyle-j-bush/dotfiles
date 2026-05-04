return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers", -- IMPORTANT: show buffers, not Vim tabs
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        separator_style = "slant",
        -- Show buffer numbers for easy navigation
        numbers = "ordinal",
        -- Show file icons
        show_buffer_icons = true,
        -- Show current working directory in bufferline
        custom_areas = {
          right = function()
            return {
              {
                text = "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":~"),
                fg = "#a9b1d6",
                bg = "#1a1b26",
              }
            }
          end,
        },
      },
    },
  },
}
