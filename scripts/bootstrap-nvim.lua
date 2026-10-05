-- Run with -u NONE so startup failures propagate as script errors/nonzero exit.
local config = vim.fn.stdpath('config')
vim.go.loadplugins = true -- -u NONE / -l disables it; Lazy requires it for setup.
vim.opt.rtp:prepend(config)
dofile(config .. '/init.lua')
require('lazy').install({ wait = true })
assert(vim.v.errmsg == '', vim.v.errmsg)
require('lazy').load({ plugins = { 'nvim-treesitter' } })
require('nvim-treesitter')
  .install({
    'bash',
    'c',
    'diff',
    'dockerfile',
    'hcl',
    'html',
    'javascript',
    'jsdoc',
    'json',
    'json5',
    'lua',
    'luadoc',
    'luap',
    'markdown',
    'markdown_inline',
    'printf',
    'python',
    'query',
    'regex',
    'terraform',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'xml',
    'yaml',
  })
  :wait(300000)
assert(vim.v.errmsg == '', vim.v.errmsg)
print('LazyVim plugins and Treesitter parsers installed.')
