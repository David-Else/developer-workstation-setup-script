require 'paq' {
  'savq/paq-nvim',
  'davidgranstrom/nvim-markdown-preview',
  'Mofiqul/vscode.nvim',
  'neovim/nvim-lspconfig',
  -- 'folke/lua-dev.nvim',
  'kosayoda/nvim-lightbulb',
  'folke/zen-mode.nvim',
  'numToStr/Comment.nvim',
  'jose-elias-alvarez/null-ls.nvim',
  'nvim-lua/plenary.nvim',
  'junegunn/fzf',
  'junegunn/fzf.vim',
  'L3MON4D3/LuaSnip',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-cmdline',
  'saadparwaiz1/cmp_luasnip',
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd 'TSUpdate'
    end,
  },
}

require('Comment').setup({})

require('nvim-lightbulb').setup { autocmd = { enabled = true } }

require('zen-mode').setup {
  window = {
    width = 83,
    backdrop = 1,
  },
}

require('luasnip.loaders.from_vscode').lazy_load { paths = { './vscode-snippets' } }
local luasnip = require 'luasnip'
local cmp = require 'cmp'
local cmp_kinds = {
  Text = '  ',
  Method = '  ',
  Function = '  ',
  Constructor = '  ',
  Field = '  ',
  Variable = '  ',
  Class = '  ',
  Interface = '  ',
  Module = '  ',
  Property = '  ',
  Unit = '  ',
  Value = '  ',
  Enum = '  ',
  Keyword = '  ',
  Snippet = '  ',
  Color = '  ',
  File = '  ',
  Reference = '  ',
  Folder = '  ',
  EnumMember = '  ',
  Constant = '  ',
  Struct = '  ',
  Event = '  ',
  Operator = '  ',
  TypeParameter = '  ',
}
cmp.setup {
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = (cmp_kinds[vim_item.kind] or '') .. vim_item.kind
      return vim_item
    end,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}), -- check empty table worked!
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<C-c>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua' },
    { name = 'luasnip', keyword_length = 2 },
    { name = 'path' },
    { name = 'buffer', keyword_length = 4 },
  },
}
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    -- 'vim', needs Neovim update to work
    'bash',
    'css',
    'html',
    'javascript',
    'jsdoc',
    'json',
    'jsonc',
    'lua',
    'rust',
    'typescript',
    'tsx',
    'markdown',
    'markdown_inline'
  },
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      scope_incremental = '<CR>',
      node_incremental = '<TAB>',
      node_decremental = '<S-TAB>',
    },
  },
  indent = {
    enable = true,
  },
}
