#!/bin/bash
set -eo pipefail
source colors.bash
source functions.bash
confirm_user_is 'normal'

idle_delay=2400
title_bar_buttons_on="true"
clock_show_date="true"
capslock_delete="true"
night_light="true"

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
# Font settings for sub-pixel rendering
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
stow --verbose --dir="$HOME/.dotfiles" --target="$HOME" neovim mpv shell autostart lazygit kitty

#==============================================================================
# Increase inotify watchers for watching large numbers of files, default is 8192
#
# curl -s https://raw.githubusercontent.com/fatso83/dotfiles/master/utils/scripts/inotify-consumers | bash
#==============================================================================
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# create template file for nautilus
touch "$HOME/Templates/text-file.txt"

display_text "

${BOLD}Congratulations, everything is installed!${RESET}
===============================================================================

Gnome:    settings  > details > choose default applications
          software  > install 'Hide Top Bar'

Install Firefox extensions
--------------------------
${GREEN}flatpak run org.mozilla.firefox${RESET} (RHEL) or ${GREEN}firefox

https://addons.mozilla.org/en-GB/firefox/addon/privacy-badger17/ \
https://addons.mozilla.org/en-GB/firefox/addon/ublock-origin/ \
https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/${RESET}

Setup vale 
-----------------------------------------------------------
Change the ${GREEN}~/.vale.ini${RESET} StylesPath = to the full path of your home directory, relative doesn't work, I couldn't use ~!

Create/update Deno completions
------------------------------
${GREEN}deno completions bash > deno.sh${RESET}
${GREEN}sudo mv deno.sh /etc/profile.d${RESET}

Install the Microsoft vale style guide
--------------------------------------
${GREEN}curl -LOf https://github.com/errata-ai/Microsoft/releases/latest/download/Microsoft.zip${RESET}
${GREEN}unzip Microsoft.zip -d ~/styles${RESET}
${GREEN}rm Microsoft.zip${RESET}

# Create example dirs and settings files
${GREEN}mkdir -p ~/styles/Vocab/tech-blogging && touch ~/styles/Vocab/tech-blogging/{accept.txt,reject.txt}${RESET}

Please reboot (or things may not work as expected)
===============================================================================
"
