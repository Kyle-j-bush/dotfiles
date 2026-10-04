-- Run with -u NONE so startup failures propagate as script errors/nonzero exit.
local config = vim.fn.stdpath('config')
vim.go.loadplugins = true -- -u NONE / -l disables it; Lazy requires it for setup.
vim.opt.rtp:prepend(config)
dofile(config .. '/init.lua')
require('lazy').sync({ wait = true })
assert(vim.v.errmsg == '', vim.v.errmsg)
vim.cmd('TSBootstrap')
assert(vim.v.errmsg == '', vim.v.errmsg)
print('Neovim plugins and parsers installed.')
