local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
map('n', '<leader>Y', '"+yy', { desc = 'Copy line to system clipboard' })
map({ 'n', 'x' }, '<leader>p', '"+p', { desc = 'Paste system clipboard (local)' })

for key, direction in pairs({ h = 'Left', j = 'Down', k = 'Up', l = 'Right' }) do
  map(
    'n',
    '<C-' .. key .. '>',
    '<cmd>TmuxNavigate' .. direction .. '<cr>',
    { desc = 'Navigate ' .. direction }
  )
  map(
    'i',
    '<C-' .. key .. '>',
    '<Esc><cmd>TmuxNavigate' .. direction .. '<cr>',
    { desc = 'Navigate ' .. direction }
  )
  map(
    't',
    '<C-' .. key .. '>',
    '<C-\\><C-n><cmd>TmuxNavigate' .. direction .. '<cr>',
    { desc = 'Navigate ' .. direction }
  )
end
