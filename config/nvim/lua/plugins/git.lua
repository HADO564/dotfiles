-- Git workflow: Neogit, Diffview, Octo (GitHub PRs/issues)
-- LazyVim already ships lazygit via <leader>gg — we extend on top of that.

return {
  -- ── Neogit: git porcelain inside nvim ──────────────────────────────────────
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    opts = {
      integrations = { diffview = true, telescope = true },
    },
  },

  -- ── Diffview: side-by-side diffs and file history ──────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>",            desc = "Diff View" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>",   desc = "File History" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>",           desc = "Close Diff" },
    },
  },

  -- ── Octo: GitHub issues & PRs inside nvim ──────────────────────────────────
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    keys = {
      { "<leader>Go", "<cmd>Octo<cr>",                desc = "Octo" },
      { "<leader>Gi", "<cmd>Octo issue list<cr>",     desc = "Issues" },
      { "<leader>Gp", "<cmd>Octo pr list<cr>",        desc = "Pull Requests" },
      { "<leader>Gc", "<cmd>Octo pr create<cr>",      desc = "Create PR" },
      { "<leader>Gr", "<cmd>Octo review start<cr>",   desc = "Review PR" },
    },
    opts = {
      default_remote = { "upstream", "origin" },
    },
  },
}
