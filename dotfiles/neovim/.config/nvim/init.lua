-- NVIM v0.7.0 config
vim.opt.title = true
vim.opt.titlelen = 33
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.swapfile = false
vim.opt.scrolloff = 8 -- screen lines to keep above/below the cursor
vim.opt.clipboard = 'unnamedplus' -- use register '+' instead of '*'
vim.opt.wrap = false -- turn off soft wrapping, turn on with autocmd
vim.opt.linebreak = true -- break at word boundaries when 'wrap' is on
vim.opt.tabstop = 2 -- spaces that a <Tab> in the file counts for
vim.opt.expandtab = true -- use appropriate number of spaces to insert a <Tab>
vim.opt.shiftwidth = 2 -- spaces inserted for indentation
vim.opt.completeopt = 'menuone,noselect'
vim.opt.updatetime = 250 -- used for the CursorHold autocommand event
vim.opt.signcolumn = 'yes' -- add gutter space for LSP info on left
vim.opt.inccommand = 'split' -- live preview in split window
vim.g.loaded_matchit = 1 -- disable matchit pluginto allow % to be remapped
vim.g.markdown_folding = 1
vim.g.fzf_preview_window = { 'up:75%', 'ctrl-/' }
vim.g.fzf_layout = { window = { width = 1, height = 1 } }
vim.g.do_filetype_lua = 1 -- use filetype.lua (will be default in 0.8)
vim.g.did_load_filetypes = 0 -- don't load filetype.vim

local init_group = vim.api.nvim_create_augroup('init_group', {})
vim.api.nvim_create_autocmd('TermOpen', {
  command = 'startinsert',
  group = init_group,
})
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'term://*',
  command = 'startinsert',
  group = init_group,
})
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight on yank',
  callback = function()
    vim.highlight.on_yank()
  end,
  group = init_group,
})
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.md', '*.txt' },
  command = 'setlocal wrap',
  group = init_group,
})
-- TODO https://github.com/kosayoda/nvim-lightbulb/pull/35 adds "CursorHoldI"
vim.api.nvim_create_autocmd({ 'CursorHold' }, {
  desc = 'nvim-lightbulb',
  callback = require('nvim-lightbulb').update_lightbulb,
  group = init_group,
})

-- ==================
--     Statusline
-- ==================
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'word count for the statusline',
  pattern = { '*.md', '*.txt' },
  callback = function()
    local wc = vim.fn.wordcount().words
    if wc == 0 then
      vim.b.wordcount = ''
    elseif wc == 1 then
      vim.b.wordcount = wc .. ' word'
    else
      vim.b.wordcount = wc .. ' words'
    end
  end,
  group = init_group,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'FocusGained' }, {
  desc = 'git branch and LSP errors for the statusline',
  callback = function()
    if vim.fn.isdirectory '.git' ~= 0 then
      -- always runs in the current directory, rather than in the buffer's directory
      local branch = vim.fn.system "git branch --show-current | tr -d '\n'"
      vim.b.branch_name = '  ' .. branch .. ' '
    end

    local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    -- if there are any errors only show the error count, don't include the number of warnings
    if num_errors > 0 then
      vim.b.errors = '  ' .. num_errors .. ' '
      return
    end
    -- otherwise show amount of warnings, or nothing if there aren't any.
    local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if num_warnings > 0 then
      vim.b.errors = '  ' .. num_warnings .. ' '
      return
    end
    vim.b.errors = ''
  end,
  group = init_group,
})

vim.opt.laststatus = 3 -- use global statusline
vim.opt.statusline =
  [[%#PmenuSel#%{get(b:, "branch_name", "")}%#LineNr# %f %m %= %#CursorColumn# %{get(b:, "errors", "")} %{get(b:, "wordcount", "")} %y %{&fileencoding?&fileencoding:&encoding} [%{&fileformat}] %p%% %l:%c]]

-- ==================
--      Plugins
-- ==================
require 'paq' {
  'savq/paq-nvim',
  'Mofiqul/vscode.nvim',
  'neovim/nvim-lspconfig',
  'kosayoda/nvim-lightbulb',
  'folke/zen-mode.nvim',
  'numToStr/Comment.nvim',
  'jose-elias-alvarez/null-ls.nvim',
  'nvim-lua/plenary.nvim',
  'junegunn/fzf.vim',
  'hrsh7th/nvim-cmp',
  'L3MON4D3/LuaSnip',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-cmdline',
  'saadparwaiz1/cmp_luasnip',
  'rafamadriz/friendly-snippets',
  {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      vim.cmd 'TSUpdate'
    end,
  },
}

require('Comment').setup()

require('zen-mode').setup {
  window = {
    width = 83,
    backdrop = 1,
  },
}

require('luasnip.loaders.from_vscode').lazy_load()
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
    ['<C-Space>'] = cmp.mapping.complete(),
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
    { name = 'luasnip' },
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
    'vim',
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

vim.g.vscode_style = 'dark'
vim.cmd [[colorscheme vscode]]

-- ==================
--    Keybindings
-- ==================
vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('t', 'jk', [[<C-\><C-n>]])

vim.keymap.set('n', '<leader>z', '<Cmd>ZenMode<CR>', { silent = true })
vim.keymap.set('n', '<leader>f', '<Cmd>Files!<CR>')
vim.keymap.set('n', '<leader>b', '<Cmd>Buffers!<CR>')
vim.keymap.set('n', '<leader>h', '<Cmd>History!<CR>')
vim.keymap.set('n', '<leader>/', '<Cmd>Rg!<CR>')

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- operations are sent to the black hole register, not unnamedplus
vim.keymap.set('n', 'c', '"_c')
vim.keymap.set('n', 'C', '"_C')
vim.keymap.set('n', 'd', '"_d')
vim.keymap.set('n', 'D', '"_D')

vim.keymap.set({ 'n', 'i' }, '<c-s>', '<Cmd>update<CR>', { silent = true })
vim.keymap.set('v', '<c-s>', '<Cmd>update<CR>', { silent = true })
vim.keymap.set('i', '<C-H>', '<C-W>') -- ctrl-backspace to delete previous word
vim.keymap.set('n', '<leader>qa', '<Cmd>confirm qall<CR>')
vim.keymap.set('n', 'q', '<Nop>') -- disable recording
vim.keymap.set('n', 'c-z', '<Nop>') -- disable suspending
vim.keymap.set({ 'n', 'v' }, 'gl', '$')
vim.keymap.set({ 'n', 'v' }, 'gh', '0')
vim.keymap.set({ 'n', 'v' }, 'gs', '^')
vim.keymap.set('n', '%', 'ggVG')
vim.keymap.set('v', '%', '<Nop>')
vim.keymap.set('n', '<leader>tv', '<Cmd>vsplit<bar>term<CR>')
vim.keymap.set('n', '<leader>ts', '<Cmd>split<bar>term<CR>')
vim.keymap.set('n', '<Leader>s', function() -- toggle spelling
  vim.o.spell = not vim.o.spell
end)
vim.keymap.set('n', '<Leader>n', function() -- toggle line numbers
  vim.o.number = not vim.o.number
end)
vim.keymap.set('n', '<Leader>c', function() -- toggle colour column
  local default_value = { 81 }
  local value = vim.inspect(vim.opt.colorcolumn:get())
  if value == '{}' then
    vim.opt.colorcolumn = default_value
  else
    vim.opt.colorcolumn = {}
  end
end)

-- ==================
--        LSP
-- ==================
vim.diagnostic.config { virtual_text = false, float = { focusable = false } }

-- show the popup diagnostics window once for the current cursor location
-- preventing it overwriting other popups triggered after at the same location
LspDiagnosticsPopupHandler = function()
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }

  if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
    vim.w.lsp_diagnostics_last_cursor = current_cursor
    vim.diagnostic.open_float(0, { scope = 'cursor' })
  end
end

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, opts)
  vim.api.nvim_create_user_command('Format', vim.lsp.buf.formatting, {})

  -- turn off formatting for selected servers (use null-ls instead)
  if client.name == 'jsonls' or client.name == 'tsserver' or client.name == 'html' then
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
  end

  vim.api.nvim_create_autocmd({ 'CursorHold' }, {
    desc = 'show diagnostics when the cursor is over an error',
    callback = function()
      LspDiagnosticsPopupHandler()
    end,
    group = init_group,
  })
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require 'lspconfig'
for _, lsp in ipairs { 'bashls', 'cssls', 'html', 'tsserver', 'eslint' } do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

-- add vim user dictionary for ltex-ls
local path = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
local words = {}

for word in io.open(path, 'r'):lines() do
  table.insert(words, word)
end

lspconfig.ltex.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ltex = {
      -- additionalRules = {
      --   languageModel = '~/ngrams/',
      -- },
      disabledRules = {
        ['en-US'] = { 'PROFANITY' },
        ['en-GB'] = { 'PROFANITY' },
      },
      dictionary = {
        ['en-US'] = words,
        ['en-GB'] = words,
      },
    },
  },
}

-- ==================
--    null-ls.nvim
-- ==================
local null_ls = require 'null-ls'
local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.deno_fmt,
    null_ls.builtins.formatting.prettier.with {
      disabled_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    }, -- use deno instead
    null_ls.builtins.formatting.stylua.with {
      extra_args = { '--config-path', vim.fn.expand '~/.stylua.toml' },
    },
    null_ls.builtins.formatting.shfmt.with {
      extra_args = { '-i', '4' },
    },
    null_ls.builtins.diagnostics.gitlint.with {
      extra_args = { '--contrib=contrib-title-conventional-commits', '--ignore=body-is-missing' },
    },
    -- null_ls.builtins.diagnostics.vale,
  },
  on_attach = function(client, bufnr)
    if client.supports_method 'textDocument/formatting' then
      vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd('BufWritePre', {
        desc = 'format on save',
        group = augroup,
        buffer = bufnr,
        callback = function()
          -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.formatting_sync()
        end,
      })
    end
  end,
}
