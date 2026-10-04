return {
  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    opts = {
      'default-title',
      winopts = { height = 0.85, width = 0.9, preview = { layout = 'vertical' } },
      files = { fd_opts = '--color=never --type f --hidden --exclude .git' },
      grep = {
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden -g !.git',
      },
    },
    keys = {
      {
        '<leader>ff',
        function()
          require('fzf-lua').files()
        end,
        desc = 'Find project files',
      },
      {
        '<leader>fr',
        function()
          require('fzf-lua').oldfiles({ cwd_only = true })
        end,
        desc = 'Find recent project files',
      },
      {
        '<leader>fb',
        function()
          require('fzf-lua').buffers()
        end,
        desc = 'Find buffers',
      },
      {
        '<leader>fg',
        function()
          require('fzf-lua').live_grep()
        end,
        desc = 'Find text (grep)',
      },
      {
        '<leader>f/',
        function()
          require('fzf-lua').blines()
        end,
        desc = 'Find current-buffer lines',
      },
      {
        '<leader>fv',
        function()
          require('fzf-lua').git_files()
        end,
        desc = 'Find versioned files',
      },
      {
        '<leader>fs',
        function()
          require('fzf-lua').lsp_document_symbols()
        end,
        desc = 'Find document symbols',
      },
      {
        '<leader>fS',
        function()
          require('fzf-lua').lsp_live_workspace_symbols()
        end,
        desc = 'Find workspace symbols',
      },
      {
        '<leader>fd',
        function()
          require('fzf-lua').diagnostics_workspace()
        end,
        desc = 'Find diagnostics',
      },
      {
        '<leader>fc',
        function()
          require('fzf-lua').command_history()
        end,
        desc = 'Find editor command history',
      },
      {
        '<leader>fh',
        function()
          require('fzf-lua').helptags()
        end,
        desc = 'Find help',
      },
      {
        'gr',
        function()
          require('fzf-lua').lsp_references()
        end,
        desc = 'Find references',
      },
    },
  },
  {
    'stevearc/oil.nvim',
    lazy = false,
    opts = {
      default_file_explorer = true,
      columns = { 'permissions', 'size' },
      skip_confirm_for_simple_edits = false,
      view_options = { show_hidden = true },
      keymaps = { ['<C-h>'] = false, ['<C-l>'] = false },
    },
  },
  { 'nvim-mini/mini.surround', event = 'VeryLazy', opts = {} },
  { 'nvim-mini/mini.ai', event = 'VeryLazy', opts = { n_lines = 200 } },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
      vim.g.tmux_navigator_disable_when_zoomed = 1
    end,
    config = function()
      for key, direction in pairs({ h = 'Left', j = 'Down', k = 'Up', l = 'Right' }) do
        vim.keymap.set(
          'n',
          '<C-' .. key .. '>',
          '<cmd>TmuxNavigate' .. direction .. '<cr>',
          { desc = 'Navigate ' .. direction }
        )
        vim.keymap.set(
          'i',
          '<C-' .. key .. '>',
          '<Esc><cmd>TmuxNavigate' .. direction .. '<cr>',
          { desc = 'Navigate ' .. direction }
        )
        vim.keymap.set(
          't',
          '<C-' .. key .. '>',
          '<C-\\><C-n><cmd>TmuxNavigate' .. direction .. '<cr>',
          { desc = 'Navigate ' .. direction }
        )
      end
    end,
  },
}
