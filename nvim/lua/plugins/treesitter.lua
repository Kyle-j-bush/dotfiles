local parsers = {
  'bash',
  'dockerfile',
  'hcl',
  'javascript',
  'json',
  'json5',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'terraform',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- Current rewritten API, not the frozen master/configs API.
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({})
      vim.treesitter.language.register('json5', 'jsonc')
      vim.api.nvim_create_user_command('TSBootstrap', function()
        require('nvim-treesitter').install(parsers):wait(300000)
      end, { desc = 'Install the curated parser set' })
      -- Parser installation is explicit; normal startup never installs/builds anything.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('dotfiles-treesitter', { clear = true }),
        callback = function(event)
          if vim.api.nvim_buf_line_count(event.buf) > 20000 then
            return
          end
          if pcall(vim.treesitter.start, event.buf) then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldlevel = 99
          end
        end,
      })
    end,
  },
}
