#!/bin/bash

GREEN="\e[38;5;46m"
BOLD="\e[1m"
RESET="\e[0m"

set -eo pipefail
source functions.bash
confirm_user_is 'normal'

detect_os
clear

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

#==============================================================================
# Stow config files, first move and backup files that would cause stow errors
#==============================================================================
[ -f "$HOME/.bash_profile" ] && mv "$HOME/.bash_profile" "$HOME/.bash_profile_backup"
[ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc" "$HOME/.bashrc_backup"
[ -f "$HOME/.config/kitty/kitty.conf" ] && mv "$HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf_backup"

mkdir -p "$HOME/.dotfiles"
cp -R ./dotfiles/* "$HOME/.dotfiles"
stow --verbose --dir="$HOME/.dotfiles" --target="$HOME" mpv shell autostart kitty pandoc # lazygit does not work for unknown reasons

# create template file for nautilus
touch "$HOME/Templates/text-file.txt"

# set the protocol to use for git clone and push operations for GitHub CLI
gh config set git_protocol ssh

display_text "
${BOLD}Congratulations, everything is setup!${RESET}

Please reboot to finish installation and setup...
"
