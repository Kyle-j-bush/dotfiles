return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      current_line_blame = false,
      on_attach = function(buf)
        local gs = require('gitsigns')
        local function map(lhs, rhs, desc, mode)
          vim.keymap.set(mode or 'n', lhs, rhs, { buffer = buf, desc = desc })
        end
        map(']h', function()
          gs.nav_hunk('next')
        end, 'Next Git hunk')
        map('[h', function()
          gs.nav_hunk('prev')
        end, 'Previous Git hunk')
        map('<leader>gs', gs.stage_hunk, 'Stage hunk')
        map('<leader>gr', gs.reset_hunk, 'Reset hunk (destructive)')
        map('<leader>gs', function()
          gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, 'Stage selected hunk', 'x')
        map('<leader>gp', gs.preview_hunk, 'Preview hunk')
        map('<leader>gb', gs.blame_line, 'Blame line')
        map('<leader>gd', gs.diffthis, 'Diff buffer against index')
        map('<leader>gD', function()
          gs.diffthis('HEAD')
        end, 'Diff buffer against HEAD')
        map('ih', gs.select_hunk, 'Inside Git hunk', { 'o', 'x' })
      end,
    },
  },
}
