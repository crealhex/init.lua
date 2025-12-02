return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  --version = false,
  build = "make",
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "echasnovski/mini.icons",
  },
  opts = {
    provider = "openai",
    openai = {
      model = "gpt-4.1",
      reasoning_effort = "high",
    },
  },
}
