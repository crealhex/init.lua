return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()
    require("nvim-treesitter").install({
      --"vimdoc", "javascript", "typescript", "c", "lua",
      --"jsdoc", "bash",
      "c",
      "java",
      "lua",
      "markdown",
      "yaml",
      "kotlin",
    })
  end
}
