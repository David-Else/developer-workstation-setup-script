#!/bin/bash

set -euo pipefail
source functions.bash
confirm_user_is 'normal'

GREEN="\e[38;5;46m"
RESET="\e[0m"
BIN_INSTALL_DIR=/usr/local/bin
SOURCE_DIR=~/src/helix # helix source code directory
TERMINAL=kitty         # terminal program to use for desktop integration

#==============================================================================
# Set host name
#==============================================================================
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# Fonts
#==============================================================================
read -p "Use sub-pixel rendering? (recommended for monitors with less than 4k resolution) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_to_file "$HOME/.Xresources" "Xft.lcdfilter: lcddefault"
    dconf write /org/gnome/settings-daemon/plugins/xsettings/antialiasing "'rgba'"
    echo "Sub-pixel rendering on"
fi

# create template file for nautilus
touch "$HOME/Templates/text-file.txt"

# set the protocol to use for git clone and push operations for GitHub CLI
gh config set git_protocol ssh
#==============================================================================
# Install remaining binaries
#==============================================================================

# deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# tt
sudo curl -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt-linux -o $BIN_INSTALL_DIR/tt && sudo chmod +x $BIN_INSTALL_DIR/tt
sudo curl -o /usr/share/man/man1/tt.1.gz -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt.1.gz

# rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer
# symlink rust-analyzer executable, won't be needed after https://github.com/rust-lang/rustup/pull/3022
[ ! -e /usr/local/bin/rust-analyzer ] && sudo ln -s $(rustup which rust-analyzer) /usr/local/bin/rust-analyzer

# install helix from source and compile
mkdir -p $SOURCE_DIR
git clone https://github.com/helix-editor/helix $SOURCE_DIR
cd $SOURCE_DIR || exit
git checkout 0dbee9590baed10bef3c6c32420b8a5802204657 # hand picked stable point
cargo install --path helix-term

# add desktop files
cp contrib/Helix.desktop ~/.local/share/applications
cp contrib/helix.png ~/.icons
sed -i "s|Exec=hx %F|Exec=$TERMINAL hx %F|g" ~/.local/share/applications/Helix.desktop
sed -i "s|Terminal=true|Terminal=false|g" ~/.local/share/applications/Helix.desktop

# symlink runtime files
cd ~/.config/helix || exit
[ ! -e ./runtime ] && ln -s $SOURCE_DIR/runtime . # if there is no symlink create one to the source directory
