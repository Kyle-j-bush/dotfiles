return {
  {
    'nvim-mini/mini.files',
    opts = {
      options = { permanent_delete = false },
    },
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
  },
}
