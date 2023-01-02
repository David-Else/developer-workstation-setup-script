### Neovim custom key mappings

```
General                                    LSP
-------                                    ---
       jk = escape                         gD        = jumps to the declaration
   ctrl-s = save                           gd        = jumps to the definition
 gh/gl/gs = goto line start/end/1st char   <space>k  = displays hover information
<space>p  = paste from 0 register          ctrl-k    = displays signature info
<space>ts = open terminal below            gi        = lists all implementations
<space>tv = open terminal to the right                 in the quickfix window
<space>qa = quit all                       gr        = list all symbol references
<space>c  = toggle colorcolumn             <space>wa = add workspace folder
<space>n  = toggle line numbers            <space>wr = remove workstation folder
<space>z  = toggle zen mode                <space>wl = list workstation folders
<space>d  = toggle diagnostics             <space>D  = jump to type definition
                                           <space>r  = rename all symbol references
fzf.vim                                    <space>a  = selects a code action
-------
<space>f  = open file explorer
<space>b  = open buffers                   Diagnostics
<space>h  = open file history              -----------
<space>/  = ripgrep search results         <space>e  = show diagnostics from line
                                           <space>l  = sets the location list
ctrl-/     = toggle preview window         [d        = move to previous diagnostic
ctrl-t/x/v = open in new tab/split/vert    ]d        = move to next diagnostic


Comment-nvim
------------
NORMAL                                      VISUAL

gcc = toggles line using linewise comment   gc  = Toggles the region using linewise comment
gbc = toggles line using blockwise comment  gb  = Toggles the region using blockwise comment
```

For all the Vim/Neovim built in shortcuts please check out
https://www.elsewebdevelopment.com/ultimate-vim-keyboard-shortcuts/

### Neovim plugins

This is a list of all the plugins used, please follow the links to read about
how to operate them.

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Nvim
  Treesitter configurations and abstraction layer
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - Quickstart
  configurations for the Nvim LSP client
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp/) - Auto completion plugin for
  Nvim written in Lua
- [nvim-lightbulb](https://github.com/kosayoda/nvim-lightbulb) - Shows a
  lightbulb whenever a `textDocument/codeAction` is available at the current
  cursor position
- [nvim-markdown-preview](https://github.com/davidgranstrom/nvim-markdown-preview) -
  Markdown preview in the browser using pandoc/live-server through Neovim's
  job-control API
- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) - Distraction-free
  coding for Neovim
- [null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim) - Use
  Neovim as a language server to inject LSP diagnostics, code actions, and more
  via Lua

- [comment.nvim](https://github.com/numToStr/Comment.nvim) - Comment stuff out
- [fzf.vim](https://github.com/junegunn/fzf.vim) - fzf vim wrapper
