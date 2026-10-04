local group = vim.api.nvim_create_augroup('dotfiles', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  callback = function()
    vim.hl.on_yank({ timeout = 120 })
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'python',
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = group,
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end
    local function map(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map('gd', vim.lsp.buf.definition, 'Definition')
    map('gD', vim.lsp.buf.declaration, 'Declaration')
    map('gi', vim.lsp.buf.implementation, 'Implementation')
    map('gy', vim.lsp.buf.type_definition, 'Type definition')
    map('K', vim.lsp.buf.hover, 'Hover documentation')
    map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('<leader>cs', vim.lsp.buf.signature_help, 'Signature help')
    if client.name == 'ruff' then
      client.server_capabilities.hoverProvider = false -- basedpyright owns hover/types.
    end
  end,
})
vim.diagnostic.config({
  virtual_text = { spacing = 2, source = 'if_many' },
  virtual_lines = false,
  severity_sort = true,
  update_in_insert = false,
  float = { border = 'rounded', source = true },
})
