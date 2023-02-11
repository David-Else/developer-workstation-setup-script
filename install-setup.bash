#!/bin/bash
set -euo pipefail
source functions.bash
confirm_user_is 'normal'

bin_install_folder=/usr/local/bin
helix_src_folder=~/src/helix # helix source code directory
helix_config_folder=~/.config/helix
terminal_program=kitty # terminal program to use for desktop integration

#==============================================================================
# Set host name
#==============================================================================
clear
read -rp "What is this computer's name? [$HOSTNAME] " hostname
if [[ ! -z "$hostname" ]]; then
    hostnamectl set-hostname "$hostname"
fi

#==============================================================================
# sub-pixel rendering
#==============================================================================
read -p "Use sub-pixel rendering? (recommended for monitors with less than 4k resolution) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    add_to_file "$HOME/.Xresources" "Xft.lcdfilter: lcddefault"
    dconf write /org/gnome/settings-daemon/plugins/xsettings/antialiasing "'rgba'"
    echo "Sub-pixel rendering on"
fi

#==============================================================================
# Install remaining binaries and setup
#==============================================================================
# deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# tt
sudo curl -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt-linux -o $bin_install_folder/tt && sudo chmod +x $bin_install_folder/tt
sudo curl -o /usr/share/man/man1/tt.1.gz -L https://github.com/lemnos/tt/releases/download/v0.4.2/tt.1.gz

# rust and rust-analyzer
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup component add rust-analyzer
[ ! -e $bin_install_folder/rust-analyzer ] && sudo ln -s "$(rustup which rust-analyzer)" $bin_install_folder/rust-analyzer # https://github.com/rust-lang/rustup/pull/3022

# install helix from source and add desktop files
mkdir -p $helix_src_folder
git clone https://github.com/helix-editor/helix $helix_src_folder
git -C $helix_src_folder checkout 3b301a9d1d832d304ff109aa9f5eee025789b3e8 # hand picked stable point
cargo install --locked --path $helix_src_folder/helix-term
[ ! -e $helix_config_folder/runtime ] && ln -s $helix_src_folder/runtime $helix_config_folder # if there is no symlink create one to the source directory

mkdir -p ~/.icons
cp $helix_src_folder/contrib/helix.png ~/.icons
cp $helix_src_folder/contrib/Helix.desktop ~/.local/share/applications
sed -i "s|Exec=hx %F|Exec=$terminal_program hx %F|g;s|Terminal=true|Terminal=false|g" ~/.local/share/applications/Helix.desktop

# create template file for nautilus
touch "$HOME/Templates/text-file.txt"

# set the protocol to use for git clone and push operations for GitHub CLI
gh config set git_protocol ssh
