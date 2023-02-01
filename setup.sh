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

# create template file for nautilus
touch "$HOME/Templates/text-file.txt"

# set the protocol to use for git clone and push operations for GitHub CLI
gh config set git_protocol ssh

display_text "
${BOLD}Congratulations, everything is setup!${RESET}

Please reboot to finish installation and setup...
"
