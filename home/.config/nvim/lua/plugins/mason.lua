return {
  {
    "mason-org/mason.nvim",
    cmd = {
      "Mason",
      "MasonUpdate",
      "MasonInstall",
      "MasonUninstall",
      "MasonLog",
    },
    opts = {
      PATH = "prepend",
      ui = {
        border = "rounded",
      },
    },
  },
}
