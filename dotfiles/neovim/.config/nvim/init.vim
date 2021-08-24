"=================="
"    Functions     "
"=================="

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

function GitCommit() abort
  let message = input('Enter commit message: ')
  call system("git commit -m '" . message . "'")
endfunction

"=================="
"  Load plugins    "
"=================="

call plug#begin('~/.config/nvim/plugged')
  " use built-in LSP and treesitter features
  Plug 'nvim-treesitter/nvim-treesitter', { 'branch': '0.5-compat', 'do': ':TSUpdate' }
  Plug 'neovim/nvim-lspconfig'
  " auto completion and LSP codeAction alert
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'kosayoda/nvim-lightbulb'
  " preview markdown in web browser using pandoc
  Plug 'davidgranstrom/nvim-markdown-preview'
  " fuzzy find
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " zen mode
  Plug 'folke/zen-mode.nvim'
  " popup with possible key bindings as you type
  Plug 'folke/which-key.nvim'
  " comment stuff out
  Plug 'tpope/vim-commentary'
call plug#end()

lua require("lsp")

"=================="
" Global Settings  "
"=================="

colorscheme codedark

set noswapfile
set splitright
set splitbelow
set scrolloff=8       " set number of screen lines to keep above/below the cursor
set linebreak         " soft wrap long lines at a character in 'breakat'
set inccommand=split  " shows the effects of a command incrementally as you type (note: this is now a default on master)
set hidden            " keep buffer windows open (note: this is now a default on master)
set cmdwinheight=14   " increase height of the command-line window
set tabstop=2         " number of spaces that a <Tab> in the file counts for
set expandtab         " use the appropriate number of spaces to insert a <Tab>
set shiftwidth=2      " number of spaces inserted for indentation
set ssop-=options     " do not store global and local values in a session
set termguicolors     " set to true color
set title             " change terminal title to name of file
set signcolumn=yes    " add gutter space for LSP info on left
set updatetime=100    " increased to LSP code actions appear faster
set nospell spelllang=en_us
set completeopt=menu,menuone,noselect " options for insert mode completion
set guicursor+=n-v-c:blinkon1         " set cursor to blink
set clipboard=unnamedplus             " use clipboard register '+' instead of '*'
set grepprg=rg\ --vimgrep\ --smart-case\ --hidden " use rg when using grep command
set grepformat=%f:%l:%c:%m
let g:markdown_folding = 1 " enable markdown folding (doesn't work in after/ftplugin)

"=================="
"   Autocommands   "
"=================="

augroup reset_group
  autocmd!
augroup END

autocmd reset_group TermOpen * startinsert
autocmd reset_group TermClose term://* close
autocmd reset_group BufEnter term://* startinsert
autocmd reset_group TextYankPost * silent! lua require'vim.highlight'.on_yank()
autocmd reset_group CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
autocmd reset_group QuickFixCmdPost [^l]* cwindow
autocmd reset_group QuickFixCmdPost    l* lwindow
" to create session: :mks [optional session filename]
autocmd reset_group VimLeave * if !empty(v:this_session) | exe "mksession! ".(v:this_session)

" use deno LSP for formatting these instead
" autocmd FileType javascript setlocal formatprg=prettier\ --parser\ typescript
" autocmd FileType javascript.jsx setlocal formatprg=prettier\ --parser\ typescript
" autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript

"=================="
"  Setup Plugins   "
"=================="

lua << EOF
require("which-key").setup {
  plugins = {             
    spelling = {          
      enabled = true,     
      suggestions = 20,   
    },                    
  },
}

require("zen-mode").setup {
  window = {
    width = 81, -- width of the Zen window
  },
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "css", "html", "javascript", "json", "jsonc", "lua", "rust", "typescript" },
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      scope_incremental = "<CR>",
      node_incremental = "<TAB>",
      node_decremental = "<S-TAB>",
    },
  },
}

local cmp = require('cmp')
cmp.setup {
  mapping = {
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  sources = {
    { name = 'nvim_lsp' },
  },
}
EOF

"==========================================="
"         Custom Key Mappings               "
"==========================================="

let mapleader = "\<Space>"
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" set ctrl-backspace to delete previous word
inoremap <C-H> <C-W>

" make Y act like C and D (note: this is now a default on master)
nnoremap Y y$

" keep cursor position when joining lines
nnoremap J mxJ'x

" set undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" go to next spelling error and prompt for correction
nmap <silent><leader>sn ]sz=

" quit all but confirm if buffer unsaved 
nnoremap <silent><leader>qa :confirm qall<CR>

" open new terminal to the right
nnoremap <silent><leader>t :vsplit<bar>term<CR>

" disable netrw loading and replace broken link opening https://github.com/vim/vim/issues/4738
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
nnoremap <silent> gx :execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<CR>

" insert new line in normal mode
nnoremap <silent><leader>o m`o<Esc>``

" toggle zen mode
nnoremap <silent><leader>z :ZenMode<CR>

" run make on current buffer
nnoremap <leader>m :make %<CR>

" change working directory to the location of the current file
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" format entire buffer and keep cursor position with mark
nnoremap <silent><leader>f mxgggqG'x<CR>

" open init.vim file
nnoremap <silent><leader>c :e $MYVIMRC<CR>

" toggle colorcolumn
nnoremap <silent><leader>cc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" toggle line numbers
nnoremap <silent><leader>n :set invnumber<CR>

" toggle spell checking
nnoremap <silent><leader>s :set invspell<CR>

" toggle showing white spaces
set lcs+=space:.
nnoremap <silent><leader>w :set list!<CR>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<CR>
inoremap <silent><c-s> <c-o>:update<CR>
vnoremap <silent><c-s> <c-c>:update<CR>gv

" esc to turn off search highlighting
nnoremap <silent><esc> :noh<CR>

" use `ALT+{h,j,k,l}` to navigate windows from any mode
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

let g:fzf_preview_window = ['right:60%', 'ctrl-/']
nnoremap <silent><c-p> :Files!<CR>
nnoremap <silent><leader>b :Buffers!<CR>
nnoremap <silent><leader>h :History!<CR>
nnoremap <silent><leader>gs :GFiles?<CR>
nnoremap <silent><leader>gh :BCommits!<CR>
nnoremap <silent><leader>rg :Rg!<CR>

" cycle through quicklist/:helpgrep items
nnoremap [c :cprevious<CR>
nnoremap ]c :cnext<CR>
" cycle through location list items
nnoremap [l :lprevious<CR>
nnoremap ]l :lnext<CR>

" git add buffer / add to staging area
nnoremap <leader>ga :!git add %<CR>
" git reset buffer / lossless unstage
nnoremap <leader>gr :!git reset %<CR>
" git commit
nnoremap <leader>gc :call GitCommit()<CR>
" git push
nnoremap <leader>gp :!git push<CR>

"=================="
"   Disable keys   "
"=================="

" disable accidentally pressing ctrl-z and suspending
nnoremap <c-z> <Nop>

" disable recording
nnoremap q <Nop>

" disable arrow keys
noremap  <Up>    <Nop>
noremap  <Down>  <Nop>
noremap  <Left>  <Nop>
noremap  <Right> <Nop>
inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>

"======================================="
"        Movement Mappings              "
"======================================="

" line without new line character
onoremap l :silent normal 0vg_<CR>

"======================================="
"            Status Line                "
"======================================="

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 

