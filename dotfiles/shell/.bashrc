# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$HOME/.deno/bin:$HOME/Documents/scripts:$HOME/adb-fastboot/platform-tools/:$PATH"
fi
export PATH

# User specific aliases and functions
alias ls="ls -ltha --color --group-directories-first --hyperlink=auto"
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100"
alias diff="diff -u --color=always" # add '| less -r' for full color output using less
alias nnn="nnn -x"                  # -x selection to system clipboard, add -e open text in $EDITOR

clip() { xclip -sel clip -rmlastnl; }

ghpr() { GH_FORCE_TTY=100% gh pr list --limit 300 |
    fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window 'down,70%' --header-lines 3 |
    awk '{print $1}' |
    xargs gh pr checkout; }

wordcount() { pandoc --lua-filter wordcount.lua "$@"; }

[ -n "$NNNLVL" ] && PS1="N$NNNLVL $PS1" # prompt you are within a shell that will return you to nnn
export NNN_PLUG="f:fzcd;p:preview-tui;m:mtpmount"
export NNN_BMS="d:~/Documents;p:~/Pictures;v:~/Videos;m:~/Music;h:~/;u:/run/media/$USERNAME;D:~/Downloads;M:/run/user/$UID/gvfs"
export NNN_TRASH=1 # use trash-cli: https://pypi.org/project/trash-cli/
export NNN_FIFO=/tmp/nnn.fifo

export BAT_THEME="Visual Studio Dark+"
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git}"'
export video_pref="bestvideo[height<=?2160]+bestaudio/best"
export thumbnail_viewer="kitty"

stty -ixon      # disable terminal flow control to free ctrl-s for shortcut
stty werase \^H # set ctrl-backspace to delete previous word instead of ctrl-w

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
