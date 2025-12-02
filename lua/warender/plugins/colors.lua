return {
  {
    'rebelot/kanagawa.nvim',
  },
  { 'rose-pine/neovim', name = 'rose-pine' },
  { 'catppuccin/nvim', name = 'catppuccin' },
  {
    'dgox16/oldworld.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('oldworld')
    end
  },
  {
    'ellisonleao/gruvbox.nvim',
    config = function()
      require('gruvbox').setup {
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = false
        },
        bold = false,
        contrast = "soft"
      }
    end
  },
  { 'sainnhe/gruvbox-material' }
}
