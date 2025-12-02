return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      -- A list of parser names, or "all"
      ensure_installed = {
        --"vimdoc", "javascript", "typescript", "c", "lua", "rust",
        --"jsdoc", "bash",
        "c",
        "java",
        "lua",
        "markdown",
        "yaml",
        "kotlin",
      },
    })
  end
}
