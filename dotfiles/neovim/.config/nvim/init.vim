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

"=================="
"  Load plugins    "
"=================="

call plug#begin('~/.config/nvim/plugged')
  " use built-in LSP and treesitter features
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'
  Plug 'neovim/nvim-lspconfig'
  " auto completion and LSP codeAction alert
  Plug 'hrsh7th/nvim-compe'
  Plug 'kosayoda/nvim-lightbulb'
  " preview markdown in web browser using pandoc
  Plug 'davidgranstrom/nvim-markdown-preview'
  " fuzzy find
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  " zen mode
  Plug 'folke/zen-mode.nvim'
call plug#end()

lua require("lsp")

"=================="
"     Settings     "
"=================="

colorscheme codedark

set noswapfile
set splitright
set splitbelow
set linebreak         " soft wrap long lines at a character in 'breakat'
set inccommand=split  " shows the effects of a command incrementally as you type
set hidden            " keep buffer windows open
set cmdwinheight=14   " increase height of the command-line window
set tabstop=2         " number of spaces that a <Tab> in the file counts for
set expandtab         " use the appropriate number of spaces to insert a <Tab>
set shiftwidth=2      " number of spaces inserted for indentation
set ssop-=options     " do not store global and local values in a session
set termguicolors     " set to true color
set title             " change terminal title to name of file
set signcolumn=yes    " add gutter space for lsp info on left
set updatetime=100    " increased to lsp code actions appear faster
set nospell spelllang=en_us
set completeopt=menu,menuone,noselect " options for insert mode completion
set guicursor+=n-v-c:blinkon1         " set cursor to blink
set clipboard=unnamedplus             " use clipboard register '+' instead of '*'

let g:markdown_fenced_languages = ['bash=sh', 'javascript', 'js=javascript', 'json=javascript', 'typescript', 'ts=typescript', 'php', 'html', 'css', 'rust', 'sql']
let g:markdown_folding = 1

"=================="
"   Autocommands   "
"=================="

augroup markdown_start_folds_open
  autocmd!
  au FileType markdown setlocal foldlevel=99 conceallevel=2
augroup END

augroup new_terminal_enter_insert_mode
  autocmd!
  au TermOpen * startinsert
augroup END

augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

" to create session: :mks [optional session filename]
augroup sessions_save_on_exit
  autocmd!
  autocmd VimLeave * if !empty(v:this_session) | exe "mksession! ".(v:this_session)
augroup END

augroup lightbulb_code_action
  autocmd!
  autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
augroup END

augroup formatting 
  autocmd!
  autocmd FileType sh setlocal formatprg=shfmt\ -i\ 4
  autocmd FileType markdown setlocal formatprg=prettier\ --parser\ markdown
  autocmd FileType css setlocal formatprg=prettier\ --parser\ css
  autocmd FileType html setlocal formatprg=prettier\ --parser\ html
  autocmd FileType json setlocal formatprg=prettier\ --parser\ json
" use deno LSP for formatting these instead
"  autocmd FileType javascript setlocal formatprg=prettier\ --parser\ typescript
"  autocmd FileType javascript.jsx setlocal formatprg=prettier\ --parser\ typescript
"  autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript
augroup END

"=================="
"  Setup Plugins   "
"=================="

lua << EOF
require("zen-mode").setup {
  window = {
    width = 80, -- width of the Zen window
    },
  }

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "css", "html", "javascript", "json", "jsonc", "lua", "rust", "typescript" },
  highlight = {
    enable = true,
  },
}

require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
}
EOF

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.source = {'path': v:true, 'buffer': v:true, 'nvim_lsp': v:true, 'spell': v:true }

inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

"==========================================="
"         Custom Key Mappings               "
"       (also see LSP mappings)             "
"                                           "
"          jk = escape                      "
"      ctrl-s = save                        "
"         ESC = search highlighting off     "
"                                           "
"  <leader>f  = format (formatprg or LSP)   "
"  <leader>l  = lint using shellcheck       "
"  <leader>cd = working dir to current file "
"  <leader>c  = edit init.vim config        "
"  <leader>o  = insert newline below        "
"  <leader>qa = quit all                    "
"                                           "
"  <leader>cc = toggle colorcolumn          "
"  <leader>n  = toggle line numbers         "
"  <leader>s  = toggle spell check          "
"  <leader>w  = toggle whitespaces          "
"  <leader>z  = toggle zen mode             "
"                                           "
"  fzf.vim                                  "
"  -------                                  "
"  ctrl-p     = open file explorer          "
"  <leader>b  = open buffers                "
"  <leader>h  = open file history           "
"  <leader>rg = ripgrep search results      "
"                                           "
"  <leader>gs = git status                  "
"  <leader>gc = git commits history         "
"                                           " 
"  text objects                             "
"  ------------                             "
"      ["af"] = @function.outer             "
"      ["if"] = @function.inner             "
"      ["ac"] = @class.outer                "
"      ["ic"] = @class.inner                "
"==========================================="

let mapleader = "\<Space>"
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" quit all but confirm if buffer unsaved 
nnoremap <silent><leader>qa :confirm qall<CR>

" disable netrw loading and replace broken link opening https://github.com/vim/vim/issues/4738
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
nnoremap <silent> gx :execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<cr>

" insert new line in normal mode
nnoremap <silent><leader>o m`o<Esc>``

" toggle zen mode
nnoremap <silent><leader>z :ZenMode<CR>

" lint current buffer using shellcheck
nnoremap <leader>l :vsplit term://shellcheck -x %<CR>

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
nnoremap <silent><leader>s :set invspell<cr>

" toggle showing white spaces
set lcs+=space:.
nnoremap <silent><leader>w :set list!<cr>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<cr>
inoremap <silent><c-s> <c-o>:update<cr>
vnoremap <silent><c-s> <c-c>:update<cr>gv

" esc to turn off search highlighting
nnoremap <silent><esc> :noh<cr>

let g:fzf_preview_window = ['right:60%', 'ctrl-/']
nnoremap <silent><c-p> :Files!<CR>
nnoremap <silent><leader>b :Buffers!<CR>
nnoremap <silent><leader>h :History!<CR>
nnoremap <silent><leader>gs :GFiles?<CR>
nnoremap <silent><leader>gc :BCommits!<CR>
nnoremap <silent><leader>rg :Rg!<CR>

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

