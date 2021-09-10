-- modified from https://github.com/neovim/nvim-lspconfig#keybindings-and-completion 3rd May 2021
-- npm i -g vscode-langservers-extracted bash-language-server

local nvim_lsp = require 'lspconfig'

local null_ls = require 'null-ls'
local sources = {
  null_ls.builtins.formatting.prettier,
  null_ls.builtins.formatting.stylua,
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

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
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

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap('v', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
  end

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

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { 'bashls', 'jsonls', 'cssls', 'html', 'null-ls' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

-- Add the deno language server with linting enabled
nvim_lsp.denols.setup {
  on_attach = on_attach,
  init_options = {
    lint = true,
  },
}

-- Turn off virtual text
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
})
-- Show diagnostics on cursor over and stop window being focusable
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]
-- Show function signature help while typing
vim.cmd [[autocmd CursorHoldI * silent! lua vim.lsp.buf.signature_help()]]
