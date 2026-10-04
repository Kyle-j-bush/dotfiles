return {
  {
    'nvim-mini/mini.statusline',
    lazy = false,
    opts = { use_icons = false },
    init = function()
      vim.cmd.colorscheme('habamax')
    end,
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 500,
      icons = { mappings = false },
      spec = {
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git hunks' },
        { '<leader>c', group = 'code' },
        { '<leader>b', group = 'buffers' },
      },
    },
  },
}
