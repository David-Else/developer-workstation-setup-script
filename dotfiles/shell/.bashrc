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

export NNN_PLUG="p:addtoplaylist;f:fzcd"
export NNN_BMS='d:~/Documents;D:~/Downloads;p:~/Pictures;v:~/Videos;m:~/Music;h:~/'
export NNN_TRASH=1 # use trash-cli: https://pypi.org/project/trash-cli/

export BAT_THEME="Visual Studio Dark+"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git}"'
export YTFZF_PREF="bestvideo[height<=?1080]+bestaudio/best"

stty -ixon # disable terminal flow control to free ctrl-s for shortcut

# alias code="GTK_IM_MODULE=ibus code" # for RHEL 8 and clones
