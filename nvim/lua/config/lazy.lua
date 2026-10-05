vim.g.mapleader = ' '
vim.g.maplocalleader = ','
vim.g.lazyvim_python_lsp = 'basedpyright'
vim.g.lazyvim_python_ruff = 'ruff'

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local result = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('lazy.nvim bootstrap failed:\n' .. result)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    { import = 'lazyvim.plugins.extras.coding.mini-surround' },
    { import = 'lazyvim.plugins.extras.editor.mini-files' },
    { import = 'lazyvim.plugins.extras.lang.docker' },
    { import = 'lazyvim.plugins.extras.lang.json' },
    { import = 'lazyvim.plugins.extras.lang.python' },
    { import = 'lazyvim.plugins.extras.lang.terraform' },
    { import = 'lazyvim.plugins.extras.lang.yaml' },
    { import = 'plugins' },
  },
  defaults = { lazy = true, version = false },
  install = { colorscheme = { 'habamax' } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = 'rounded' },
})
