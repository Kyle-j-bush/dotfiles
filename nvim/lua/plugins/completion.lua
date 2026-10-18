return {
  {
    'saghen/blink.cmp',
    opts = function(_, opts)
      opts.keymap = opts.keymap or {}
      opts.keymap.preset = 'super-tab' -- Tab accepts completions; Enter inserts a newline.
      opts.keymap['<C-k>'] = { 'fallback' } -- Leave split navigation to tmux.
      opts.keymap['<C-f>'] = { 'fallback' } -- tmux reserves Ctrl-f for the project picker.
    end,
  },
}
