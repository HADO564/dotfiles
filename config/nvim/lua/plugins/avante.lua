return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    -- `make` compiles with cargo; without cargo (e.g. macOS) fetch the prebuilt libraries
    build = vim.fn.executable("cargo") == 1 and "make" or "bash ./build.sh",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-6",
          timeout = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens = 8096,
          },
        },
      },
    },
  },
}
