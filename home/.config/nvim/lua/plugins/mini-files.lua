return {
  {
    "nvim-mini/mini.files",
    version = false,
    keys = {
      {
        "<leader>fm",
        function()
          local buf_name = vim.api.nvim_buf_get_name(0)

          -- If current buffer is a real file, open mini.files at that file.
          -- This focuses the file in its parent directory.
          if buf_name ~= "" and vim.uv.fs_stat(buf_name) then
            require("mini.files").open(buf_name, false)
          else
            -- Otherwise open current working directory.
            require("mini.files").open(vim.uv.cwd(), false)
          end
        end,
        desc = "Mini Files",
      },
      {
        "<leader>fM",
        function()
          require("mini.files").open(vim.uv.cwd(), false)
        end,
        desc = "Mini Files CWD",
      },
    },
    opts = {
      -- Keep it clean and lightweight.
      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },

      windows = {
        preview = true,
        width_focus = 30,
        width_nofocus = 18,
        width_preview = 60,
      },

      mappings = {
        close = "q",
        go_in = "l",
        go_in_plus = "L",
        go_out = "h",
        go_out_plus = "H",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },
    },
  },
}
