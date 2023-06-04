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

# Aliases
alias ls="ls -ltha --color --group-directories-first --hyperlink=auto"
alias tree="tree -Catr --noreport --dirsfirst --filelimit 100"
alias mpv="flatpak run io.mpv.Mpv"
alias avif="heif-enc -A -q 85"            # encode avif at almost lossless quality
alias hg="kitty +kitten hyperlinked_grep" # https://sw.kovidgoyal.net/kitty/kittens/hyperlinked_grep/

# Functions
clip() { xclip -sel clip -rmlastnl; }

md() {
    filename="${1##*/}"
    pandoc --embed-resources --standalone "$1" -o /tmp/"$filename".html
    xdg-open /tmp/"$filename".html
}

ghpr() { GH_FORCE_TTY=100% gh pr list --limit 300 |
    fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window 'down,70%' --header-lines 3 |
    awk '{print $1}' |
    xargs gh pr checkout; }

wordcount() { pandoc --lua-filter wordcount.lua "$@"; }

# nnn
[ -n "$NNNLVL" ] && PS1="N$NNNLVL $PS1" # prompt you are within a shell that will return you to nnn
export NNN_PLUG="f:fzcd;p:preview-tui;m:mtpmount"
export NNN_BMS="d:~/Documents;p:~/Pictures;v:~/Videos;m:~/Music;h:~/;u:/run/media/$USERNAME;D:~/Downloads;M:${XDG_CONFIG_HOME:-$HOME/.config}/nnn/mounts"
export NNN_TRASH=1 # use trash-cli: https://pypi.org/project/trash-cli/
export NNN_FIFO=/tmp/nnn.fifo

# bat
export BAT_THEME="Visual Studio Dark+"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --no-ignore-vcs -g "!{node_modules,.git}"'

# ytfzf
export video_pref="bestvideo[height<=?2160]+bestaudio/best"

stty -ixon      # disable terminal flow control to free ctrl-s for shortcut
stty werase \^H # set ctrl-backspace to delete previous word instead of ctrl-w

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
