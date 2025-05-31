return {
    -- Completion engine
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
  
        -- Load friendly snippets
        require("luasnip.loaders.from_vscode").lazy_load()
  
        cmp.setup({
          -- Auto popup enabled (default behavior)
          completion = {
            autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
          },
  
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
  
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"]     = cmp.mapping.select_next_item(),
            ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
            ["<CR>"]      = cmp.mapping.confirm({ select = true }),
            ["<C-e>"]     = cmp.mapping.close(),   -- Close suggestions but stay in insert mode
            ["<C-Space>"] = cmp.mapping.complete() -- Manually trigger suggestions
          }),
  
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
  
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
        })
      end
    }
  }
  