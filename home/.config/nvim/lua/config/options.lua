-- Options are loaded before LazyVim startup.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable netrw. We use mini.files instead.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Keep LazyVim formatter/linter behavior.
vim.g.autoformat = true

-- Use LazyVim picker setup.
vim.g.lazyvim_picker = "snacks"

-- Less visual noise.
vim.g.snacks_animate = false

-- Editor feel.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.confirm = true

-- Indentation.
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Search.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits.
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Diagnostics/signs.
vim.opt.updatetime = 250

-- Completion.
vim.opt.completeopt = "menu,menuone,noselect"
