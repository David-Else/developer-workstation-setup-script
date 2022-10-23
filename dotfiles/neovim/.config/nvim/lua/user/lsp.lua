require'lspconfig'.marksman.setup{}

local init_lsp_on_attach_group = vim.api.nvim_create_augroup('init_lsp_on_attach_group', {})
vim.diagnostic.config { virtual_text = false, float = { focusable = false, source = "if_many" } }

-- show the popup diagnostics window once for the current cursor location
-- this prevents it overwriting other popups triggered after
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
    client.server_capabilities.document_formatting = false
    client.server_capabilities.document_range_formatting = false
  end

  if client.server_capabilities.document_formatting then
    local au_lsp = vim.api.nvim_create_augroup("format_on_save_lsp", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      desc = 'format on save',
      callback = function()
        -- TODO on 0.8 use
        buffer = bufnr,
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
      group = au_lsp,
    })
  end

  --  stop multiple LSPs triggering multiple copies of this autocmd
  --  clear any previous copy that has the same group and buffer number
  vim.api.nvim_clear_autocmds { group = init_lsp_on_attach_group, buffer = bufnr }
  vim.api.nvim_create_autocmd('CursorHold', {
    desc = 'show diagnostics when the cursor is over an error',
    group = init_lsp_on_attach_group,
    buffer = bufnr,
    callback = function()
      LspDiagnosticsPopupHandler()
    end,
  })
end

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lspconfig = require 'lspconfig'
for _, lsp in ipairs { 'bashls', 'cssls', 'html', 'eslint' } do
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

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = {
        command = "clippy",
      },
    },
  },
}

lspconfig.denols.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json"),
}

lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    json = {
      schemas = {
        {
          fileMatch = { 'package.json' },
          url = 'https://json.schemastore.org/package.json',
        },
        {
          fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
          url = 'http://json.schemastore.org/tsconfig',
        },
        {
          fileMatch = { '.eslintrc.json', '.eslintrc' },
          url = 'http://json.schemastore.org/eslintrc',
        },
        {
          fileMatch = { '.prettierrc', '.prettierrc.json', 'prettier.config.json' },
          url = 'http://json.schemastore.org/prettierrc',
        },
        {
          fileMatch = { 'deno.json' },
          url = 'https://raw.githubusercontent.com/denoland/deno/main/cli/schemas/config-file.v1.json',
        },
      },
    },
  },
}

-- local luadev = require("lua-dev").setup({
--   lspconfig = {
--     on_attach = on_attach,
--     capabilities = capabilities,
--   },
-- })
-- lspconfig.sumneko_lua.setup(luadev)

-- ==================
--    null-ls.nvim
-- ==================
local null_ls = require 'null-ls'
local init_null_ls_on_attach_group = vim.api.nvim_create_augroup('init_null_ls_on_attach_group', {})

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.deno_fmt,
    null_ls.builtins.formatting.prettier.with {
      disabled_filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    }, -- use deno instead
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
      vim.api.nvim_clear_autocmds { group = init_null_ls_on_attach_group, buffer = bufnr }
      vim.api.nvim_create_autocmd('BufWritePre', {
        desc = 'format on save',
        group = init_null_ls_on_attach_group,
        buffer = bufnr,
        callback = function()
          -- TODO on 0.8 use vim.lsp.buf.format({ bufnr = bufnr }) instead
          vim.lsp.buf.formatting_sync()
        end,
      })
    end
  end,
}
