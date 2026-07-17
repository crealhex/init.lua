vim.opt.guicursor = "n-v-c:block-Cursor"

vim.opt.tabstop = 2           -- Number of spaces a tab counts for
vim.opt.shiftwidth = 2        -- Number of spaces for indentation
vim.opt.expandtab = true      -- Use spaces instead of tabs

vim.opt.number = true         -- Show absolute line numbers
vim.opt.relativenumber = true -- Show relative line numbers

vim.opt.colorcolumn = "100"   -- Show a vertical line at 100 characters

vim.opt.termguicolors = true

vim.opt.incsearch = true
vim.opt.scrolloff = 10

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard = "unnamedplus" -- Sync yanks/pastes with the + register

-- Force OSC 52 over the auto-detected tmux provider: tmux's load-buffer only
-- fills the tmux buffer, while OSC 52 (with tmux set-clipboard on) reaches
-- both the tmux buffer and the client terminal's system clipboard.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "OSC 52",
  copy  = { ["+"] = osc52.copy("+"),  ["*"] = osc52.copy("*") },
  paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
}
