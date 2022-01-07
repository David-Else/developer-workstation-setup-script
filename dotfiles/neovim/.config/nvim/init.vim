"=================="
"    Functions     "
"=================="

" On Centos 8 aiksaurus-1.2.1-38.fc28.x86_64.rpm works
func Thesaur(findstart, base)
    if a:findstart
	let line = getline('.')
	let start = col('.') - 1
	while start > 0 && line[start - 1] =~ '\a'
	   let start -= 1
	endwhile
	return start
    else
	let res = []
	let h = ''
	for l in split(system('aiksaurus '.shellescape(a:base)), '\n')
	    if l[:3] == '=== '
	    	let h = substitute(l[4:], ' =*$', '', '')
	    elseif l[0] =~ '\a'
		call extend(res, map(split(l, ', '), {_, val -> {'word': val, 'menu': '('.h.')'}}))
	    endif
	endfor
	return res
    endif
endfunc

function WordCount() abort
    return (&filetype ==# 'markdown' ? wordcount().words : '')
endfu

function GitBranch() abort
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function StatuslineGit() abort
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

function GitCommit() abort
  let message = input('Enter commit message: ')
  call system("git commit -m '" . message . "'")
endfunction

"=================="
"     Plugins      "
"=================="
call plug#begin('~/.config/nvim/plugged')
   Plug 'Mofiqul/vscode.nvim'
   Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
   Plug 'neovim/nvim-lspconfig'

   Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
   Plug 'junegunn/fzf.vim'

   Plug 'kosayoda/nvim-lightbulb', { 'commit': 'cd5267d2d708e908dbd668c7de74e1325eb1e1da' }
   Plug 'folke/zen-mode.nvim', { 'commit': 'f1cc53d32b49cf962fb89a2eb0a31b85bb270f7c' }
   Plug 'folke/trouble.nvim', { 'commit': '20469be985143d024c460d95326ebeff9971d714' }
   Plug 'jose-elias-alvarez/null-ls.nvim', { 'commit': '2bb7994500d7e5abcb51f067df74160fbc9e7aa3' }
   Plug 'nvim-lua/plenary.nvim', { 'commit': 'a672e11c816d4a91ef01253ba1a2567d20e08e55' }
   Plug 'davidgranstrom/nvim-markdown-preview', { 'commit': '940c856932ad81e784f16a47e24193821a8fa8fd' }
   Plug 'tpope/vim-commentary', { 'commit': '627308e30639be3e2d5402808ce18690557e8292' }

   Plug 'hrsh7th/nvim-cmp', { 'commit': '796f925915f40d4726ed4cee4497604288fae9f7' }
   Plug 'hrsh7th/cmp-nvim-lsp', { 'commit': '134117299ff9e34adde30a735cd8ca9cf8f3db81' }
   Plug 'hrsh7th/cmp-nvim-lsp-signature-help', { 'commit': 'daa6a0c2484915e855e60eeff586860c68e59d83' }
   Plug 'hrsh7th/cmp-path', { 'commit': '4d58224e315426e5ac4c5b218ca86cab85f80c79' }
   Plug 'hrsh7th/cmp-buffer', { 'commit': 'a01cfeca70594f505b2f086501e90fb6c2f2aaaa' }
   Plug 'hrsh7th/cmp-cmdline', { 'commit': '29ca81a6f0f288e6311b3377d9d9684d22eac2ec' }
call plug#end()

"=================="
"  Load Lua Setup  "
"=================="
lua require("lsp-setup")
lua require("plugin-setup")

"=================="
" Global Settings  "
"=================="
let g:vscode_style = "dark"
colorscheme vscode

set noswapfile
set splitright splitbelow
set thesaurusfunc=Thesaur   " use the 'thesaurusfunc' for external thesaurus
set scrolloff=8             " screen lines to keep above/below the cursor
set linebreak               " soft wrap long lines at a character in 'breakat'
set tabstop=2               " spaces that a <Tab> in the file counts for
set expandtab               " use appropriate number of spaces to insert a <Tab>
set shiftwidth=2            " spaces inserted for indentation
set ssop-=options           " don't store global and local values in a session
set termguicolors           " use true color
set title                   " change terminal title to name of file
set signcolumn=yes          " add gutter space for LSP info on left
set updatetime=100          " increased so LSP code actions appear faster
set completeopt=menu,menuone,noselect " options for insert mode completion
set guicursor+=n-v-c:blinkon1         " set cursor to blink
set clipboard=unnamedplus             " use register '+' instead of '*'
set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
set grepformat=%f:%l:%c:%m
let g:fzf_preview_window = ['up:75%', 'ctrl-/']
let g:fzf_layout = { 'window': { 'width': 1, 'height': 1 } }
let g:markdown_folding = 1
let g:markdown_fenced_languages = [
  \ 'bash=sh', 'javascript', 'js=javascript', 'typescript',
  \ 'ts=typescript', 'php', 'html', 'css', 'rust', 'sql']

"=================="
"   Autocommands   "
"=================="
augroup reset_group
  autocmd!
augroup END

" start a terminal, and return to an open terminal in insert mode
autocmd reset_group TermOpen * startinsert
autocmd reset_group BufEnter term://* startinsert
" save active session on exit, create a session :mks [optional session filename]
autocmd reset_group VimLeave * if !empty(v:this_session) | exe "mksession! ".(v:this_session)
" show highlight on yank
autocmd reset_group TextYankPost * silent! lua require'vim.highlight'.on_yank()

"==========================================="
"         Custom Key Mappings               "
"==========================================="
let mapleader = "\<Space>"

"==================
"   trouble.nvim
"==================
nnoremap <leader>xx <cmd>TroubleToggle<cr>
nnoremap <leader>xw <cmd>TroubleToggle workspace_diagnostics<cr>
nnoremap <leader>xd <cmd>TroubleToggle document_diagnostics<cr>
nnoremap <leader>xq <cmd>TroubleToggle quickfix<cr>
nnoremap <leader>xl <cmd>TroubleToggle loclist<cr>
nnoremap gR <cmd>TroubleToggle lsp_references<cr>

"==================
"  zen-mode.nvim
"==================
nnoremap <silent><leader>z :ZenMode<CR>

"==================
"     fzf.vim
"==================
nnoremap <silent><c-p> :Files!<CR>
nnoremap <silent><leader>b :Buffers!<CR>
nnoremap <silent><leader>h :History!<CR>
nnoremap <silent><leader>gs :GFiles?<CR>
nnoremap <silent><leader>gh :BCommits!<CR>
nnoremap <silent><leader>rg :Rg!<CR>

" escape key
inoremap jk <Esc>
tnoremap jk <C-\><C-n>

" set ctrl-backspace to delete previous word
inoremap <C-H> <C-W>

" change operations are sent to the black hole register, not unnamed
nnoremap c "_c
nnoremap C "_C

" keep cursor position when joining lines
nnoremap J mxJ'x

" set more undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" quit all confirming, if buffer unsaved 
nnoremap <silent><leader>qa :confirm qall<CR>

" open new split window terminals
nnoremap <silent><leader>tv :vsplit<bar>term<CR>
nnoremap <silent><leader>ts :split<bar>term<CR>

" change working directory to the location of the current file
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" toggle colorcolumn
nnoremap <silent><leader>cc :execute "set colorcolumn=" . (&colorcolumn == "" ? "80" : "")<CR>

" toggle line numbers
nnoremap <silent><leader>n :set invnumber<CR>

" toggle showing white spaces
set lcs+=space:.
nnoremap <silent><leader>w :set list!<CR>

" ctrl-s to save (add stty -ixon to ~/.bashrc required)
nnoremap <silent><c-s> :<c-u>update<CR>
inoremap <silent><c-s> <c-o>:update<CR>
vnoremap <silent><c-s> <c-c>:update<CR>gv

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

" git
nnoremap <leader>ga :!git add %<CR>
nnoremap <leader>gr :!git reset %<CR>
nnoremap <leader>gc :call GitCommit()<CR>
" nnoremap <silent><leader>gc :vsplit<bar>:term git commit<CR>
nnoremap <leader>gp :!git push<CR>

" disable accidentally pressing ctrl-z and suspending
nnoremap <c-z> <Nop>

" disable recording
nnoremap q <Nop>

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
set statusline+=%{WordCount()}

