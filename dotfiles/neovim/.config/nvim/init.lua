-- NVIM v0.8.0 config
require('user.statusline')
require('user.thesaurus')
require('user.plugins')
-- if vim.g.lsp_executed == nil then --- load once preventing multiple copies of language servers
require('user.lsp')
-- vim.g.lsp_executed = true
-- end

vim.cmd [[colorscheme vscode]]

vim.opt.title = true -- window title is 'titlestring' or 'filename [+=-] (path)'
vim.opt.titlelen = 33 -- percentage of 'columns' for the length of window title

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.foldmethod = 'expr' -- use 'foldexpr' to define folds
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()' -- use treesitter for folds
vim.opt.foldnestmax = 3
vim.opt.foldenable = false -- turn folding off, can be toggled with 'zi'

vim.opt.wrap = false -- soft wrapping, can be toggled with an autocmd
vim.opt.linebreak = true -- breaks at word boundaries when 'wrap' is on
vim.opt.expandtab = true -- insert spaces whenever the <Tab> key is pressed
vim.opt.tabstop = 2 -- number of spaces inserted when the <Tab> key is pressed
vim.opt.shiftwidth = 2 -- spaces for indentation, also used by sumneko ls

vim.opt.swapfile = false
vim.opt.scrolloff = 8 -- screen lines to keep above/below the cursor
vim.opt.clipboard = 'unnamedplus' -- use '+' register instead of '*'
vim.opt.completeopt = 'menuone,noselect'
vim.opt.updatetime = 250 -- used for the CursorHold autocmd event
vim.opt.signcolumn = 'yes' -- gutter space for LSP info on left
vim.opt.inccommand = 'split' -- live preview in split window

vim.g.markdown_folding = 1 -- uses runtime filetype, not treesitter
vim.g.fzf_preview_window = { 'up:75%', 'ctrl-/' }
vim.g.fzf_layout = { window = { width = 1, height = 1 } }

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
  callback = function()
    vim.opt.wrap = true
  end,
  group = init_group,
})

vim.g.mapleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- vim.keymap.set('n', '<leader>vs', function()
--   for name, _ in pairs(package.loaded) do
--     if name:match('^user') then
--       package.loaded[name] = nil
--     end
--   end
--   dofile(vim.env.MYVIMRC)
-- end)

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('t', 'jk', [[<C-\><C-n>]])

-- paste from 0 register containing most recent yank
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"0p')
vim.keymap.set('n', '<leader>P', '"0P')

vim.keymap.set('n', '<leader>z', '<Cmd>ZenMode<CR>', { silent = true })
vim.keymap.set('n', '<leader>f', '<Cmd>Files!<CR>')
vim.keymap.set('n', '<leader>b', '<Cmd>Buffers!<CR>')
vim.keymap.set('n', '<leader>h', '<Cmd>History!<CR>')
vim.keymap.set('n', '<leader>/', '<Cmd>Rg!<CR>')

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>l', vim.diagnostic.setloclist)

vim.keymap.set({ 'n', 'i' }, '<c-s>', '<Cmd>update<CR>', { silent = true })
vim.keymap.set('v', '<c-s>', '<Cmd>update<CR>', { silent = true })
vim.keymap.set('i', '<C-H>', '<C-W>') -- ctrl-backspace to delete previous word
vim.keymap.set('n', '<leader>qa', '<Cmd>confirm qall<CR>')
vim.keymap.set('n', 'q', '<Nop>') -- disable recording
vim.keymap.set('n', '<c-z>', '<Nop>') -- disable suspending
vim.keymap.set({ 'n', 'v' }, 'gl', '$')
vim.keymap.set({ 'n', 'v' }, 'gh', '0')
vim.keymap.set({ 'n', 'v' }, 'gs', '^')
vim.keymap.set('n', '<leader>tv', '<Cmd>vsplit<bar>term<CR>')
vim.keymap.set('n', '<leader>ts', '<Cmd>split<bar>term<CR>')

vim.keymap.set('n', '<Leader>s', '<Cmd>set invspell<CR>') -- toggle spelling
vim.keymap.set('n', '<Leader>n', '<Cmd>set invnumber<CR>') -- toggle line numbers
vim.keymap.set('n', '<Leader>c', function() -- toggle colour column
  local default_value = { 81 }
  local value = vim.inspect(vim.opt.colorcolumn:get())
  if value == '{}' then
    vim.opt.colorcolumn = default_value
  else
    vim.opt.colorcolumn = {}
  end
end)
-- toggle diagnostics for all buffers (can go out of sync)
local diagnostics_active = true
vim.keymap.set('n', '<leader>d', function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end)
