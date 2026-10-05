return {
  {
    'folke/noice.nvim',
    opts = function(_, opts)
      opts.cmdline = opts.cmdline or {}
      opts.cmdline.view = 'cmdline' -- Keep command input on the classic bottom row.

      opts.routes = opts.routes or {}
      -- BasedPyright emits this short-lived status after each edit; keep other LSP progress.
      table.insert(opts.routes, 1, {
        filter = {
          event = 'lsp',
          kind = 'progress',
          cond = function(message)
            local progress = message.opts.progress
            return progress and progress.client == 'basedpyright'
          end,
        },
        opts = { skip = true },
      })
    end,
  },
}
