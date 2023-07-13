#!/bin/bash

set -euo pipefail
clear

# Confirm the user is either normal or root and exit if they are not
# ${1} normal|root
confirm_user_is() {
    USER_STATUS=$(id -u)
    if [[ "$USER_STATUS" != 0 && ${1} == "root" ]]; then
        echo "You're not root! Run script with sudo" && exit 1
    elif [[ "$USER_STATUS" == 0 && ${1} == "normal" ]]; then
        echo "You're root! Run script as user" && exit 1
    fi
}
confirm_user_is 'normal'

idle_delay=1200
title_bar_buttons_on="true"
capslock_delete="true"
night_light="true"

helix_src_folder="$HOME/src/helix"
helix_config_folder="$HOME/.config/helix"
terminal_program=kitty # terminal program to use for desktop integration

#==============================================================================
# Optional sub-pixel rendering
#==============================================================================
read -p "Use sub-pixel rendering? (recommended for monitors with less than 4k resolution) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_to_file "$HOME/.Xresources" "Xft.lcdfilter: lcddefault"
    dconf write /org/gnome/settings-daemon/plugins/xsettings/antialiasing "'rgba'"
    echo "Sub-pixel rendering on"
fi

#==============================================================================
# Gnome desktop settings
#==============================================================================
gsettings set org.gnome.desktop.session \
    idle-delay $idle_delay

if [[ "${title_bar_buttons_on}" == "true" ]]; then
    gsettings set org.gnome.desktop.wm.preferences \
        button-layout 'appmenu:minimize,maximize,close'
fi

if [[ "${capslock_delete}" == "true" ]]; then
    gsettings set org.gnome.desktop.input-sources \
        xkb-options "['caps:backspace', 'terminate:ctrl_alt_bksp']"
fi

if [[ "${night_light}" == "true" ]]; then
    gsettings set org.gnome.settings-daemon.plugins.color \
        night-light-enabled true
fi

#==============================================================================
# Install and setup various programs
#==============================================================================
pipx install shell-gpt
pipx install yt-dlp
pipx ensurepath

curl -fsSL https://deno.land/x/install/install.sh | sh

if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup component add rust-analyzer
fi

# TODO this can only be run once as the helix src folder will exist, needs more checks
if ! [ -x "$(command -v hx)" ]; then
    mkdir -p "$helix_src_folder"
    git clone https://github.com/helix-editor/helix "$helix_src_folder"
    # git -C "$helix_src_folder" checkout 23.05
    cargo install --locked --path "$helix_src_folder"/helix-term
    [ ! -e "$helix_config_folder"/runtime ] && ln -s "$helix_src_folder"/runtime "$helix_config_folder" # if there is no symlink create one to the source directory

    mkdir -p "$HOME/.icons/"
    cp "$helix_src_folder"/contrib/helix.png "$HOME/.icons/"
    cp "$helix_src_folder"/contrib/Helix.desktop "$HOME/.local/share/applications"
    sed -i "s|Exec=hx %F|Exec=$terminal_program hx %F|g;s|Terminal=true|Terminal=false|g" "$HOME/.local/share/applications/Helix.desktop"
fi

touch "$HOME/Templates/text-file.txt" # create template file for nautilus

read -p "Open Firefox on pages for installing extensions and improving privacy? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    firefox https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
        https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/ \
        https://addons.mozilla.org/en-US/firefox/addon/copy-selection-as-markdown/ \
        https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/ &
fi

echo
echo "Everything is installed and setup, please log out or reboot."
