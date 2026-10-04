return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    event = 'InsertEnter',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      keymap = {
        preset = 'default',
        ['<C-k>'] = { 'fallback' }, -- Keep Ctrl-k available for split navigation.
        ['<C-f>'] = { 'fallback' }, -- tmux reserves Ctrl-f for the project picker.
      }, -- C-space trigger, C-y accept, C-n/p select, Tab snippet.
      appearance = { use_nvim_cmp_as_default = false },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      snippets = { preset = 'default' }, -- Native vim.snippet; no LuaSnip.
      fuzzy = { implementation = 'lua' }, -- No binary download/build dependency.
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        menu = { border = 'rounded' },
      },
      signature = { enabled = false }, -- Native signature mapping is sufficient.
    },
  },
}
