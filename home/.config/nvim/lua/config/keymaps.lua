-- Custom keymaps.
-- Leader is <space>.

local map = vim.keymap.set

local function project_root()
  if _G.LazyVim and LazyVim.root then
    return LazyVim.root()
  end
  return vim.uv.cwd()
end

local function snacks_files_root()
  if _G.Snacks and Snacks.picker then
    Snacks.picker.files({ cwd = project_root() })
  else
    vim.notify("Snacks picker not loaded", vim.log.levels.WARN)
  end
end

local function snacks_files_cwd()
  if _G.Snacks and Snacks.picker then
    Snacks.picker.files({ cwd = vim.uv.cwd() })
  else
    vim.notify("Snacks picker not loaded", vim.log.levels.WARN)
  end
end

local function snacks_grep()
  if _G.Snacks and Snacks.picker then
    Snacks.picker.grep({ cwd = project_root() })
  else
    vim.notify("Snacks picker not loaded", vim.log.levels.WARN)
  end
end

local function snacks_buffers()
  if _G.Snacks and Snacks.picker then
    Snacks.picker.buffers()
  else
    vim.notify("Snacks picker not loaded", vim.log.levels.WARN)
  end
end

local function snacks_recent()
  if _G.Snacks and Snacks.picker then
    Snacks.picker.recent()
  else
    vim.notify("Snacks picker not loaded", vim.log.levels.WARN)
  end
end

-- Picker-first file movement.
map("n", "<leader>e", snacks_files_root, { desc = "Find files from project root" })
map("n", "<leader>E", snacks_files_cwd, { desc = "Find files from cwd" })
map("n", "<leader>ff", snacks_files_root, { desc = "Find files" })
map("n", "<leader>fg", snacks_grep, { desc = "Live grep" })
map("n", "<leader>fb", snacks_buffers, { desc = "Buffers" })
map("n", "<leader>fr", snacks_recent, { desc = "Recent files" })

-- mini.files file view.
map("n", "<leader>fm", function()
  local ok, mini_files = pcall(require, "mini.files")
  if not ok then
    vim.notify("mini.files not loaded", vim.log.levels.WARN)
    return
  end

  local buf_name = vim.api.nvim_buf_get_name(0)

  if buf_name ~= "" and vim.uv.fs_stat(buf_name) then
    mini_files.open(buf_name, false)
  else
    mini_files.open(vim.uv.cwd(), false)
  end
end, { desc = "Mini Files" })

map("n", "<leader>fM", function()
  local ok, mini_files = pcall(require, "mini.files")
  if not ok then
    vim.notify("mini.files not loaded", vim.log.levels.WARN)
    return
  end

  mini_files.open(vim.uv.cwd(), false)
end, { desc = "Mini Files CWD" })

-- Quality-of-life.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
