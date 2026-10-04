return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      -- nvim-lspconfig supplies server definitions; native Neovim starts them.
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = {
            disableOrganizeImports = true, -- Ruff owns imports and style.
            analysis = { diagnosticMode = 'openFilesOnly', typeCheckingMode = 'standard' },
          },
        },
        before_init = function(_, config)
          local root = config.root_dir
          if root and vim.fn.executable(root .. '/.venv/bin/python') == 1 then
            config.settings.python = { pythonPath = root .. '/.venv/bin/python' }
          end
        end,
      })
      vim.lsp.config('ruff', {
        cmd = function(dispatchers, config)
          local root = config.root_dir
          local local_cmd = root and root .. '/.venv/bin/ruff'
          local command = local_cmd and vim.fn.executable(local_cmd) == 1 and local_cmd or 'ruff'
          return vim.lsp.rpc.start({ command, 'server' }, dispatchers)
        end,
      })
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            keyOrdering = false,
            schemaStore = { enable = true }, -- Upstream schema catalog, no SchemaStore plugin.
            schemas = { kubernetes = 'k8s*.{yaml,yml}' }, -- Avoid treating all YAML as Kubernetes.
          },
        },
      })
      vim.lsp.config('bashls', { settings = { bashIde = { shellcheckPath = 'shellcheck' } } })
      local servers = {
        basedpyright = 'basedpyright-langserver',
        ruff = 'ruff',
        ts_ls = 'typescript-language-server',
        jsonls = 'vscode-json-language-server',
        yamlls = 'yaml-language-server',
        bashls = 'bash-language-server',
        lua_ls = 'lua-language-server',
        terraformls = 'terraform-ls',
        dockerls = 'docker-langserver',
        marksman = 'marksman',
        eslint = 'vscode-eslint-language-server',
      }
      for server, executable in pairs(servers) do
        if vim.fn.executable(executable) == 1 then
          vim.lsp.enable(server)
        end
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format({ async = true, lsp_format = 'never' })
        end,
        mode = { 'n', 'x' },
        desc = 'Format buffer/selection',
      },
      {
        '<leader>cF',
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          vim.notify('Format on save: ' .. (vim.b.disable_autoformat and 'off' or 'on'))
        end,
        desc = 'Toggle buffer format on save',
      },
    },
    opts = {
      formatters_by_ft = {
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
      },
      format_on_save = function(buf)
        if vim.b[buf].disable_autoformat or vim.bo[buf].buftype ~= '' then
          return
        end
        if vim.api.nvim_buf_line_count(buf) > 20000 then
          return
        end
        return { timeout_ms = 1500, lsp_format = 'never' }
      end,
      -- Conform's Prettier resolver prefers node_modules/.bin over PATH.
      -- Ruff's project executable is similarly preferred when a uv venv exists.
      formatters = {
        ruff_format = {
          command = function(_, ctx)
            local root = vim.fs.root(ctx.filename, { 'pyproject.toml', '.git' })
            local local_cmd = root and root .. '/.venv/bin/ruff'
            return local_cmd and vim.fn.executable(local_cmd) == 1 and local_cmd or 'ruff'
          end,
        },
        ruff_organize_imports = {
          command = function(_, ctx)
            local root = vim.fs.root(ctx.filename, { 'pyproject.toml', '.git' })
            local local_cmd = root and root .. '/.venv/bin/ruff'
            return local_cmd and vim.fn.executable(local_cmd) == 1 and local_cmd or 'ruff'
          end,
        },
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = { dockerfile = { 'hadolint' }, markdown = { 'markdownlint-cli2' } }
      vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('dotfiles-lint', { clear = true }),
        callback = function()
          if vim.bo.buftype == '' then
            lint.try_lint()
          end
        end,
      })
      vim.keymap.set('n', '<leader>cl', function()
        if vim.bo.filetype == 'terraform' or vim.bo.filetype == 'terraform-vars' then
          local root = vim.fs.root(0, { '.terraform.lock.hcl', '.tflint.hcl', '.git' })
            or vim.fn.getcwd()
          lint.try_lint('tflint', { cwd = root }) -- Explicit, not on every Terraform save.
        else
          lint.try_lint()
        end
      end, { desc = 'Lint buffer (Terraform: project)' })
    end,
  },
}
