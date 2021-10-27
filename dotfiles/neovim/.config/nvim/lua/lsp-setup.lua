local nvim_lsp = require 'lspconfig'
local null_ls = require 'null-ls'

-- ==================
--    null-ls.nvim
-- ==================
local sources = {
  -- Use denols instead for 'javascript', 'javascriptreact', 'typescript', 'typescriptreact'
  null_ls.builtins.formatting.prettier.with {
    filetypes = {
      'vue',
      'svelte',
      'css',
      'scss',
      'html',
      'json',
      'yaml',
      'markdown',
    },
  },
  null_ls.builtins.formatting.stylua.with {
    extra_args = { '--config-path', vim.fn.expand '~/.stylua.toml' },
  },
  null_ls.builtins.formatting.shfmt.with {
    extra_args = { '-i', '4' },
  },
  null_ls.builtins.diagnostics.shellcheck,
  null_ls.builtins.diagnostics.vale,
}
null_ls.config { sources = sources }

-- ==================
--     lspconfig
-- ==================

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = '' })
end

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Format on save
  if client.resolved_capabilities.document_formatting then
    vim.cmd 'autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()'
  end

  -- Mappings
  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  -- Set autocommands conditional on server_capabilities
  -- Hightlight color taken from nvcode hi CursorLine value
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      hi LspReferenceRead guibg=#2c323c ctermbg=236 
      hi LspReferenceText guibg=#2c323c ctermbg=236
      hi LspReferenceWrite guibg=#2c323c ctermbg=236
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end
end

local on_attach_disable_formatting = function(client)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false
  return on_attach(client)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
-- turn off formatting for jsonls to use null-ls prettier
local servers = { 'bashls', 'jsonls', 'cssls', 'html', 'null-ls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = lsp == 'jsonls' and on_attach_disable_formatting or on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  }
end

-- Add the deno language server with linting enabled
nvim_lsp.denols.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  init_options = {
    lint = true,
  },
}

-- Turn off virtual text
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
})

-- Show diagnostics on cursor over and stop window being focusable
vim.cmd [[autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

-- Show function signature help while typing
vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]
