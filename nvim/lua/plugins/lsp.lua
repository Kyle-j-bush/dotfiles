return {
  -- LazyVim supports Mason, but this setup uses Homebrew, uv, and pnpm so the
  -- same language tools are available outside the editor too.
  { 'mason-org/mason.nvim', enabled = false },
  { 'mason-org/mason-lspconfig.nvim', enabled = false },
  {
    'neovim/nvim-lspconfig',
    opts = function(_, opts)
      local servers = {
        basedpyright = {
          mason = false,
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              analysis = { diagnosticMode = 'openFilesOnly', typeCheckingMode = 'standard' },
            },
          },
          before_init = function(_, config)
            local root = config.root_dir
            local python = root and root .. '/.venv/bin/python'
            if python and vim.fn.executable(python) == 1 then
              config.settings.python = { pythonPath = python }
            end
          end,
        },
        ruff = {
          mason = false,
          cmd = function(dispatchers, config)
            local root = config.root_dir
            local local_ruff = root and root .. '/.venv/bin/ruff'
            local command = local_ruff and vim.fn.executable(local_ruff) == 1 and local_ruff
              or 'ruff'
            return vim.lsp.rpc.start({ command, 'server' }, dispatchers)
          end,
        },
        ts_ls = { mason = false },
        eslint = { mason = false },
        jsonls = { mason = false },
        yamlls = {
          mason = false,
          settings = {
            yaml = {
              keyOrdering = false,
              schemas = { kubernetes = 'k8s*.{yaml,yml}' },
            },
          },
        },
        bashls = {
          mason = false,
          settings = { bashIde = { shellcheckPath = 'shellcheck' } },
        },
        lua_ls = {
          mason = false,
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = { 'vim' } },
              workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
              telemetry = { enable = false },
            },
          },
        },
        terraformls = { mason = false },
        dockerls = { mason = false },
        docker_compose_language_service = { enabled = false },
        marksman = { mason = false },
      }

      opts.servers = vim.tbl_deep_extend('force', opts.servers, servers)
    end,
  },
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.default_format_opts = opts.default_format_opts or {}
      opts.default_format_opts.lsp_format = 'never'
      opts.formatters_by_ft = vim.tbl_deep_extend('force', opts.formatters_by_ft or {}, {
        python = { 'ruff_organize_imports', 'ruff_format' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        json = { 'prettier' },
        jsonc = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        css = { 'prettier' },
        html = { 'prettier' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        lua = { 'stylua' },
        terraform = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
      })
      opts.formatters = opts.formatters or {}
      for _, name in ipairs({ 'ruff_format', 'ruff_organize_imports' }) do
        opts.formatters[name] = {
          command = function(_, ctx)
            local root = vim.fs.root(ctx.filename, { 'pyproject.toml', '.git' })
            local local_ruff = root and root .. '/.venv/bin/ruff'
            return local_ruff and vim.fn.executable(local_ruff) == 1 and local_ruff or 'ruff'
          end,
        }
      end
    end,
  },
  {
    'mfussenegger/nvim-lint',
    opts = function(_, opts)
      opts.linters_by_ft = vim.tbl_deep_extend('force', opts.linters_by_ft or {}, {
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint-cli2' },
      })
    end,
    keys = {
      {
        '<leader>cL',
        function()
          local lint = require('lint')
          if vim.bo.filetype == 'terraform' or vim.bo.filetype == 'terraform-vars' then
            local root = vim.fs.root(0, { '.terraform.lock.hcl', '.tflint.hcl', '.git' })
              or vim.fn.getcwd()
            lint.try_lint('tflint', { cwd = root })
          else
            lint.try_lint()
          end
        end,
        desc = 'Lint buffer (Terraform: project)',
      },
    },
  },
}
