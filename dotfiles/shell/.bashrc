# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$HOME/.deno/bin:$HOME/Documents/scripts:$PATH"
fi
export PATH

# User specific aliases and functions
alias ls="ls -ltha --color --group-directories-first"
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100"
alias diff="diff -u --color=always" # add '| less -r' for full color output using less
alias nnn="nnn -xe"                 # -x selection to system clipboard, -e open text in $EDITOR

clip() { xclip -sel clip -rmlastnl; }
wordcount() { pandoc --lua-filter wordcount.lua "$@"; }

[ -n "$NNNLVL" ] && PS1="N$NNNLVL $PS1" # prompt you are within a shell that will return you to nnn
export NNN_PLUG="p:addtoplaylist;f:fzcd;P:preview-tui;m:mtpmount"
export NNN_BMS="d:~/Documents;p:~/Pictures;v:~/Videos;m:~/Music;h:~/;D:~/Downloads;M:/run/user/$UID/gvfs"
export NNN_TRASH=1 # use trash-cli: https://pypi.org/project/trash-cli/
export NNN_FIFO=/tmp/nnn.fifo

export BAT_THEME="Visual Studio Dark+"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git}"'
export YTFZF_PREF="bestvideo[height<=?2160]+bestaudio/best"

stty -ixon      # disable terminal flow control to free ctrl-s for shortcut
stty werase \^H # set ctrl-backspace to delete previous word instead of ctrl-w

if [ -f "$HOME/dotfiles/neovim/.config/nvim/plugged/fzf/shell/key-bindings.bash" ]; then
    source ~/dotfiles/neovim/.config/nvim/plugged/fzf/shell/key-bindings.bash
fi
# alias code="GTK_IM_MODULE=ibus code" # for RHEL 8 and clones
