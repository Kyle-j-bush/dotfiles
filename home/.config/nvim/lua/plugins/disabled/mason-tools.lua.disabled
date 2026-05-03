return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      vim.list_extend(opts.ensure_installed, {
        -- Lua / Neovim config
        "lua-language-server",
        "stylua",

        -- Python
        "basedpyright",
        "ruff",

        -- Shell
        "bash-language-server",
        "shfmt",
        "shellcheck",

        -- Web / JS / TS
        "typescript-language-server",
        "eslint-lsp",
        "prettier",

        -- Data/config files
        "json-lsp",
        "yaml-language-server",
        "marksman",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        basedpyright = {},
        ruff = {},
        bashls = {},
        ts_ls = {},
        eslint = {},
        jsonls = {},
        yamlls = {},
        marksman = {},
      },
    },
  },
}
