local opt = vim.opt
opt.scrolloff = 6
opt.sidescrolloff = 6
opt.updatetime = 250
opt.timeoutlen = 400
opt.ttimeoutlen = 20
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.fillchars = { eob = ' ' }
opt.swapfile = true
opt.backup = false
opt.autochdir = false
opt.confirm = true
local state = vim.fn.stdpath('state')
for _, name in ipairs({ 'undo', 'swap' }) do
  local dir = state .. '/' .. name
  vim.fn.mkdir(dir, 'p', 448) -- 0700; keep recovery data out of the public repo.
  opt[name == 'swap' and 'directory' or 'undodir'] = dir .. '//'
end

if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  local function unavailable_paste()
    vim.notify(
      'SSH clipboard read disabled: paste with your terminal (Cmd-v).',
      vim.log.levels.WARN
    )
    return { {}, 'v' }
  end
  vim.g.clipboard = {
    name = 'OSC52 (write-only over SSH)',
    copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
    paste = { ['+'] = unavailable_paste, ['*'] = unavailable_paste },
  }
elseif vim.fn.has('macunix') == 1 then
  vim.g.clipboard = {
    name = 'macOS',
    copy = { ['+'] = 'pbcopy', ['*'] = 'pbcopy' },
    paste = { ['+'] = 'pbpaste', ['*'] = 'pbpaste' },
    cache_enabled = 0,
  }
end
-- Keep ordinary yanks/deletes in Neovim registers. <leader>y explicitly copies.
-- Do not set unnamedplus: SSH clipboard reads are intentionally unavailable.
