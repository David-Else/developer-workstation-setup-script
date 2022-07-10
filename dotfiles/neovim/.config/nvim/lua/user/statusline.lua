vim.opt.laststatus = 3 -- use global statusline
local init_statusline = vim.api.nvim_create_augroup('init_statusline', {})

-- ==================
--    LSP Progress
-- ==================
_G.lsp_progress = function()
  if #vim.lsp.buf_get_clients(0) == 0 then -- possible bug
    return "No Language Server"
  end
  local lsp = vim.lsp.util.get_progress_messages()[1]
  -- this is triggering and flickering in markdown, so ltexls!
  if lsp then
    local name = lsp.name or ""
    local msg = lsp.message or ""
    local percentage = lsp.percentage or 0
    local title = lsp.title or ""
    return string.format(" %%<%s: %s %s (%s%%%%) ", name, title, msg, percentage)
  end
  return ""
end

-- ==================
--    LSP Errors
-- ==================
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold' }, {
  desc = 'LSP errors',
  callback = function()
    local num_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    -- if there are any errors only show the error count, don't include the number of warnings
    if num_errors > 0 then
      vim.b.errors = '  ' .. num_errors .. ' '
      return
    end
    -- otherwise show amount of warnings, or nothing if there aren't any
    local num_warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    if num_warnings > 0 then
      vim.b.errors = '  ' .. num_warnings .. ' '
      return
    end
    vim.b.errors = ''
  end,
  group = init_statusline,
})

-- ==================
--     Word Count
-- ==================
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'word count',
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
  group = init_statusline,
})

-- ==================
--     Git Branch
-- ==================
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained' }, {
  desc = 'git branch',
  callback = function()
    local branch = vim.fn.system "git branch --show-current"
    if vim.v.shell_error == 0 then
      vim.b.branch_name = '  ' .. branch:gsub("\n", " ")
    else
      vim.b.branch_name = ''
    end
  end,
  group = init_statusline,
})

-- ==================
--     Statusline
-- ==================
vim.opt.statusline = [[%#PmenuSel#%{get(b:, "branch_name", "")}%#LineNr# %f %m]]
vim.opt.statusline:append([[%= %{get(b:, "lsp_status", "")} %{%v:lua.lsp_progress()%} %#CursorColumn# %{get(b:, "errors", "")} %{get(b:, "wordcount", "")} %y %{&fileencoding?&fileencoding:&encoding} [%{&fileformat}] %p%% %l:%c]])
