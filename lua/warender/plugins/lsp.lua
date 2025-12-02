return {
  "neovim/nvim-lspconfig",
  dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "j-hui/fidget.nvim",
  },
  config = function()
	local cmp_lsp = require("cmp_nvim_lsp")
	local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

  local noop = function() end
	require("fidget").setup({})
	require("mason").setup()
	require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls",
            "jdtls",
            "pyright",
            "clangd",
          },
          handlers = {
            function(server_name)
              require("lspconfig")[server_name].setup {
                capabilities = capabilities,
              }
            end,
            ['jdtls'] = noop,
            ["lua_ls"] = function()
              require("lspconfig").lua_ls.setup {
                root_dir = function() return vim.fn.getcwd() end,
                on_init = function(client)
                  if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc') then
                      return
                    end
                  end
                  client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                    runtime = {
                      version = "LuaJIT"
                    },
                    workspace = {
                      checkThirdParty = false,
                      library = {
                        vim.env.VIMRUNTIME
                        -- Depending on the usage, you might want to add additional paths here.
                        -- "${3rd}/luv/library"
                        -- "${3rd}/busted/library",
                      }
                    }
                  })
                end,
                settings = {
                  Lua = {}
                }
              }
            end,
          }
	})

	local cmp = require("cmp")
	local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup {
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            ["<C-Space>"] = cmp.mapping.complete(),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' }, -- For luasnip users.
          },
          {
            { name = 'buffer' },
          })
        }

        vim.diagnostic.config({
          float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        })
        vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true, silent = true })
    end
}
