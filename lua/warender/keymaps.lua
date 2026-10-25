vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', '<cmd>lua vim.lsp.buf.signature_help()<CR>',
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ca', function()
  -- jdtls sends generate actions twice (quickassist + source.*); keep the first per title
  local seen = {}
  vim.lsp.buf.code_action({
    filter = function(action, client_id)
      local key = client_id .. ':' .. action.title
      if seen[key] then
        return false
      end
      seen[key] = true
      return true
    end,
  })
end, { silent = true, desc = 'LSP: code action' })

vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
  { noremap = true, silent = true })
