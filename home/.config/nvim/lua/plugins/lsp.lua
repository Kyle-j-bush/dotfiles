return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Keep Lua/Markdown Mason-managed for now because they are already fine.
        lua_ls = {},
        marksman = {},

        -- These are installed globally through npm/pipx instead of Mason.
        -- This stops mason-lspconfig from repeatedly trying and failing to install them.
        vtsls = {
          mason = false,
        },
        jsonls = {
          mason = false,
        },
        yamlls = {
          mason = false,
        },
        bashls = {
          mason = false,
        },
        pyright = {
          mason = false,
        },
        eslint = {
          mason = false,
        },
        ruff = {
          mason = false,
        },
      },
    },
  },
}
