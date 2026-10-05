return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        'dockerfile',
        'hcl',
        'json5',
        'terraform',
      })
    end,
  },
}
