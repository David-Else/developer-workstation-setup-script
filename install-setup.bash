#!/bin/bash
# Run this script after running install.yml

set -euo pipefail
source functions.bash
confirm_user_is 'normal'
clear

idle_delay=1200
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"

bin_install_folder=/usr/local/bin
helix_src_folder="$HOME/src/helix"
helix_config_folder="$HOME/.config/helix"
terminal_program=kitty # terminal program to use for desktop integration

#==============================================================================
# Set host name
#==============================================================================
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

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

if [[ "${clock_show_date}" == "true" ]]; then
    gsettings set org.gnome.desktop.interface \
        clock-show-date true
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
curl -fsSL https://deno.land/x/install/install.sh | sh

echo
curl https://rclone.org/install.sh | sudo bash || true

sudo curl -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt-linux -o $bin_install_folder/tt && sudo chmod +x $bin_install_folder/tt
sudo curl -o /usr/share/man/man1/tt.1.gz -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt.1.gz

if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install"
fi

if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source "$HOME/.cargo/env"
    rustup component add rust-analyzer
fi

if ! [ -x "$(command -v hx)" ]; then
    mkdir -p "$helix_src_folder"
    git clone https://github.com/helix-editor/helix "$helix_src_folder"
    git -C "$helix_src_folder" checkout 23.03
    cargo install --locked --path "$helix_src_folder"/helix-term
    [ ! -e "$helix_config_folder"/runtime ] && ln -s "$helix_src_folder"/runtime "$helix_config_folder" # if there is no symlink create one to the source directory

    cp "$helix_src_folder"/contrib/helix.png "$HOME/.icons"
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
        https://restoreprivacy.com/firefox-privacy/ \
        https://addons.mozilla.org/en-US/firefox/addon/keepassxc-browser/ &
fi

echo
echo "Everything is installed and setup, please log out or reboot."
